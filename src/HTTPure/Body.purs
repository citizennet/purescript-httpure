module HTTPure.Body
  ( class Body
  , defaultHeaders
  , read
  , write
  ) where

import Prelude

import Data.Either as Either
import Effect as Effect
import Effect.Aff as Aff
import Effect.Ref as Ref
import HTTPure.Headers as Headers
import Node.Buffer as Buffer
import Node.Encoding as Encoding
import Node.HTTP as HTTP
import Node.Stream as Stream
import Type.Equality as TypeEquals

-- | Types that implement the `Body` class can be used as a body to an HTTPure
-- | response, and can be used with all the response helpers.
class Body b where

  -- | Return any default headers that need to be sent with this body type,
  -- | things like `Content-Type`, `Content-Length`, and `Transfer-Encoding`.
  -- | Note that any headers passed in a response helper such as `ok'` will take
  -- | precedence over these.
  defaultHeaders :: b -> Effect.Effect Headers.Headers

  -- | Given a body value and a Node HTTP `Response` value, write the body value
  -- | to the Node response.
  write :: b -> HTTP.Response -> Aff.Aff Unit

-- | The instance for `String` will convert the string to a buffer first in
-- | order to determine it's additional headers.  This is to ensure that the
-- | `Content-Length` header properly accounts for UTF-8 characters in the
-- | string.  Writing is simply implemented by writing the string to the
-- | response stream and closing the response stream.
instance bodyString :: Body String where

  defaultHeaders body = Buffer.fromString body Encoding.UTF8 >>= defaultHeaders

  write body response = Aff.makeAff \done -> do
    let stream = HTTP.responseAsStream response
    _ <- Stream.writeString stream Encoding.UTF8 body $ pure unit
    _ <- Stream.end stream $ pure unit
    done $ Either.Right unit
    pure Aff.nonCanceler

-- | The instance for `Buffer` is trivial--we add a `Content-Length` header
-- | using `Buffer.size`, and to send the response, we just write the buffer to
-- | the stream and end the stream.
instance bodyBuffer :: Body Buffer.Buffer where

  defaultHeaders buf =
    Headers.header "Content-Length" <$> show <$> Buffer.size buf

  write body response = Aff.makeAff \done -> do
    let stream = HTTP.responseAsStream response
    _ <- Stream.write stream body $ pure unit
    _ <- Stream.end stream $ pure unit
    done $ Either.Right unit
    pure Aff.nonCanceler

-- | This instance can be used to send chunked data.  Here, we add a
-- | `Transfer-Encoding` header to indicate chunked data.  To write the data, we
-- | simply pipe the newtype-wrapped `Stream` to the response.
instance bodyChunked ::
  TypeEquals.TypeEquals (Stream.Stream r) (Stream.Readable ()) =>
  Body (Stream.Stream r) where

  defaultHeaders _ = pure $ Headers.header "Transfer-Encoding" "chunked"

  write body response = Aff.makeAff \done -> do
    let stream = TypeEquals.to body
    _ <- Stream.pipe stream $ HTTP.responseAsStream response
    Stream.onEnd stream $ done $ Either.Right unit
    pure Aff.nonCanceler

-- | Extract the contents of the body of the HTTP `Request`.
read :: HTTP.Request -> Aff.Aff String
read request = Aff.makeAff \done -> do
  let stream = HTTP.requestAsStream request
  bufs <- Ref.new []
  Stream.onData stream \buf ->
    void $ Ref.modify (_ <> [buf]) bufs
  Stream.onEnd stream do
    body <- Ref.read bufs >>= Buffer.concat >>= Buffer.toString Encoding.UTF8
    done $ Either.Right body
  pure Aff.nonCanceler
