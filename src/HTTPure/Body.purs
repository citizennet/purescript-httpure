module HTTPure.Body
  ( class Body
  , RequestBody
  , defaultHeaders
  , write
  , read
  , toBuffer
  , toStream
  , toString
  ) where

import Prelude
import Data.Either (Either(Right))
import Data.Maybe (Maybe(Just, Nothing))
import Effect (Effect)
import Effect.Aff (Aff, makeAff, nonCanceler)
import Effect.Class (liftEffect)
import Effect.Ref (Ref)
import Effect.Ref (read, modify, new, write) as Ref
import HTTPure.ResponseHeaders (ResponseHeaders, header)
import Node.Buffer (Buffer, concat, fromString, size)
import Node.Buffer (toString) as Buffer
import Node.Encoding (Encoding(UTF8))
import Node.HTTP (Request, Response, requestAsStream, responseAsStream)
import Node.Stream (Stream, Readable, onData, onEnd, writeString, pipe, end)
import Node.Stream (write) as Stream
import Type.Equality (class TypeEquals, to)

type RequestBody =
  { buffer :: Ref (Maybe Buffer)
  , stream :: Readable ()
  , string :: Ref (Maybe String)
  }

-- | Read the body `Readable` stream out of the incoming request
read :: Request -> Effect RequestBody
read request = do
  buffer <- Ref.new Nothing
  string <- Ref.new Nothing
  pure
    { buffer
    , stream: requestAsStream request
    , string
    }

-- | Turn `RequestBody` into a `String`
-- |
-- | This drains the `Readable` stream in `RequestBody` for the first time
-- | and returns cached result from then on.
toString :: RequestBody -> Aff String
toString requestBody = do
  maybeString <-
    liftEffect
      $ Ref.read requestBody.string
  case maybeString of
    Nothing -> do
      buffer <- toBuffer requestBody
      string <- liftEffect
        $ Buffer.toString UTF8 buffer
      liftEffect
        $ Ref.write (Just string) requestBody.string
      pure string
    Just string -> pure string

-- | Turn `RequestBody` into a `Buffer`
-- |
-- | This drains the `Readable` stream in `RequestBody` for the first time
-- | and returns cached result from then on.
toBuffer :: RequestBody -> Aff Buffer
toBuffer requestBody = do
  maybeBuffer <-
    liftEffect
      $ Ref.read requestBody.buffer
  case maybeBuffer of
    Nothing -> do
      buffer <- streamToBuffer requestBody.stream
      liftEffect
        $ Ref.write (Just buffer) requestBody.buffer
      pure buffer
    Just buffer -> pure buffer
  where
  -- | Slurp the entire `Readable` stream into a `Buffer`
  streamToBuffer :: Readable () -> Aff Buffer
  streamToBuffer stream =
    makeAff \done -> do
      bufs <- Ref.new []
      onData stream \buf -> void $ Ref.modify (_ <> [ buf ]) bufs
      onEnd stream do
        body <- Ref.read bufs >>= concat
        done $ Right body
      pure nonCanceler

-- | Return the `Readable` stream directly from `RequestBody`
toStream :: RequestBody -> Readable ()
toStream = _.stream

-- | Types that implement the `Body` class can be used as a body to an HTTPure
-- | response, and can be used with all the response helpers.
class Body b where
  -- | Return any default headers that need to be sent with this body type,
  -- | things like `Content-Type`, `Content-Length`, and `Transfer-Encoding`.
  -- | Note that any headers passed in a response helper such as `ok'` will take
  -- | precedence over these.
  defaultHeaders :: b -> Effect ResponseHeaders
  -- | Given a body value and a Node HTTP `Response` value, write the body value
  -- | to the Node response.
  write :: b -> Response -> Aff Unit

-- | The instance for `String` will convert the string to a buffer first in
-- | order to determine it's additional headers.  This is to ensure that the
-- | `Content-Length` header properly accounts for UTF-8 characters in the
-- | string.  Writing is simply implemented by writing the string to the
-- | response stream and closing the response stream.
instance bodyString :: Body String where
  defaultHeaders body = do
    buf :: Buffer <- fromString body UTF8
    defaultHeaders buf
  write body response = makeAff \done -> do
    let stream = responseAsStream response
    void $ writeString stream UTF8 body $ end stream $ done $ Right unit
    pure nonCanceler

-- | The instance for `Buffer` is trivial--we add a `Content-Length` header
-- | using `Buffer.size`, and to send the response, we just write the buffer to
-- | the stream and end the stream.
instance bodyBuffer :: Body Buffer where
  defaultHeaders buf = header "Content-Length" <$> show <$> size buf
  write body response = makeAff \done -> do
    let stream = responseAsStream response
    void $ Stream.write stream body $ end stream $ done $ Right unit
    pure nonCanceler

-- | This instance can be used to send chunked data.  Here, we add a
-- | `Transfer-Encoding` header to indicate chunked data.  To write the data, we
-- | simply pipe the newtype-wrapped `Stream` to the response.
instance bodyChunked ::
  TypeEquals (Stream r) (Readable s) =>
  Body (Stream r) where
  defaultHeaders _ = pure $ header "Transfer-Encoding" "chunked"
  write body response = makeAff \done -> do
    let stream = to body
    void $ pipe stream $ responseAsStream response
    onEnd stream $ done $ Right unit
    pure nonCanceler
