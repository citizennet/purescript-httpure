module HTTPure.Body
  ( class Body
  , defaultHeaders
  , write
  , read
  , toString
  , toBuffer
  ) where

import Prelude
import Data.Either (Either(Right))
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Aff (Aff, makeAff, nonCanceler)
import Effect.Ref (read) as Ref
import Effect.Ref (new, modify)
import HTTPure.Headers (Headers, header)
import Node.Buffer (toString) as Buffer
import Node.Buffer (Buffer, concat, fromString, size)
import Node.Encoding (Encoding(UTF8))
import Node.HTTP (Request, Response, requestAsStream, responseAsStream)
import Node.Stream (write) as Stream
import Node.Stream (Stream, Readable, onData, onEnd, writeString, pipe, end)
import Type.Equality (class TypeEquals, to)

-- | Read the body `Readable` stream out of the incoming request
read :: Request -> Readable ()
read = requestAsStream

-- | Slurp the entire `Readable` stream into a `String`
toString :: Readable () -> Aff String
toString = toBuffer >=> Buffer.toString UTF8 >>> liftEffect

-- | Slurp the entire `Readable` stream into a `Buffer`
toBuffer :: Readable () -> Aff Buffer
toBuffer stream =
  makeAff \done -> do
    bufs <- new []
    onData stream \buf -> void $ modify (_ <> [ buf ]) bufs
    onEnd stream do
      body <- Ref.read bufs >>= concat
      done $ Right body
    pure nonCanceler

-- | Types that implement the `Body` class can be used as a body to an HTTPure
-- | response, and can be used with all the response helpers.
class Body b where
  -- | Return any default headers that need to be sent with this body type,
  -- | things like `Content-Type`, `Content-Length`, and `Transfer-Encoding`.
  -- | Note that any headers passed in a response helper such as `ok'` will take
  -- | precedence over these.
  defaultHeaders :: b -> Effect Headers
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
  TypeEquals (Stream r) (Readable ()) =>
  Body (Stream r) where
  defaultHeaders _ = pure $ header "Transfer-Encoding" "chunked"
  write body response = makeAff \done -> do
    let stream = to body
    void $ pipe stream $ responseAsStream response
    onEnd stream $ done $ Right unit
    pure nonCanceler
