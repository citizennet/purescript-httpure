module HTTPure.Body
  ( class Body
  , defaultHeaders
  , write
  , readAsString
  , readAsBuffer
  , read
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

-- | Read the request body as a `String`
readAsString :: Stream.Readable () -> Aff.Aff String
readAsString = internalRead (Buffer.toString Encoding.UTF8)

-- | Read the request body as a `Buffer`
readAsBuffer :: Stream.Readable () -> Aff.Aff Buffer.Buffer
readAsBuffer = internalRead pure

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
  defaultHeaders body = do
    buf :: Buffer.Buffer <- Buffer.fromString body Encoding.UTF8
    defaultHeaders buf
  write body response =
    Aff.makeAff \done -> do
      let
        stream = HTTP.responseAsStream response
      void $ Stream.writeString stream Encoding.UTF8 body
        $ Stream.end stream
        $ done
        $ Either.Right unit
      pure Aff.nonCanceler

-- | The instance for `Buffer` is trivial--we add a `Content-Length` header
-- | using `Buffer.size`, and to send the response, we just write the buffer to
-- | the stream and end the stream.
instance bodyBuffer :: Body Buffer.Buffer where
  defaultHeaders buf = Headers.header "Content-Length" <$> show <$> Buffer.size buf
  write body response =
    Aff.makeAff \done -> do
      let
        stream = HTTP.responseAsStream response
      void $ Stream.write stream body
        $ Stream.end stream
        $ done
        $ Either.Right unit
      pure Aff.nonCanceler

-- | This instance can be used to send chunked data.  Here, we add a
-- | `Transfer-Encoding` header to indicate chunked data.  To write the data, we
-- | simply pipe the newtype-wrapped `Stream` to the response.
instance bodyChunked ::
  TypeEquals.TypeEquals (Stream.Stream r) (Stream.Readable ()) =>
  Body (Stream.Stream r) where
  defaultHeaders _ = pure $ Headers.header "Transfer-Encoding" "chunked"
  write body response =
    Aff.makeAff \done -> do
      let
        stream = TypeEquals.to body
      void $ Stream.pipe stream $ HTTP.responseAsStream response
      Stream.onEnd stream $ done $ Either.Right unit
      pure Aff.nonCanceler

-- | Extract the contents of the body of the HTTP `Request`.
internalRead :: forall body. (Buffer.Buffer -> Effect.Effect body) -> Stream.Readable () -> Aff.Aff body
internalRead transform stream =
  Aff.makeAff \done -> do
    bufs <- Ref.new []
    Stream.onData stream \buf ->
      void $ Ref.modify (_ <> [ buf ]) bufs
    Stream.onEnd stream do
      body <- Ref.read bufs >>= Buffer.concat >>= transform
      done $ Either.Right body
    pure Aff.nonCanceler

read :: HTTP.Request -> Stream.Readable ()
read = HTTP.requestAsStream
