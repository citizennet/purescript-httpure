module HTTPure.Body
  ( class Body
  , read
  , size
  , write
  ) where

import Prelude

import Data.Either as Either
import Data.Maybe as Maybe
import Effect as Effect
import Effect.Aff as Aff
import Effect.Ref as Ref
import Node.Buffer as Buffer
import Node.Encoding as Encoding
import Node.HTTP as HTTP
import Node.Stream as Stream

-- | Types that implement the `Body` class can be used as a body to an HTTPure
-- | response, and can be used with all the response helpers.
class Body b where

  -- | Given a body value, return an effect that maybe calculates a size.
  -- | TODO: This is a `Maybe` to support chunked transfer encoding.  We still
  -- | need to add code to send the body using chunking if the effect resolves a
  -- | `Maybe.Nothing`.
  size :: b -> Effect.Effect (Maybe.Maybe Int)

  -- | Given a body value and a Node HTTP `Response` value, write the body value
  -- | to the Node response.
  write :: b -> HTTP.Response -> Aff.Aff Unit

-- | The instance for `String` will convert the string to a buffer first in
-- | order to determine it's size.  This is to properly handle UTF-8 characters
-- | in the string.  Writing is simply implemented by writing the string to the
-- | response stream and closing the response stream.
instance bodyString :: Body String where
  size body = Buffer.fromString body Encoding.UTF8 >>= size
  write body response = Aff.makeAff \done -> do
    let stream = HTTP.responseAsStream response
    _ <- Stream.writeString stream Encoding.UTF8 body $ pure unit
    _ <- Stream.end stream $ pure unit
    done $ Either.Right unit
    pure Aff.nonCanceler

-- | The instance for `Buffer` is trivial--to calculate size, we use
-- | `Buffer.size`, and to send the response, we just write the buffer to the
-- | stream and end the stream.
instance bodyBuffer :: Body Buffer.Buffer where
  size = Buffer.size >>> map Maybe.Just
  write body response = Aff.makeAff \done -> do
    let stream = HTTP.responseAsStream response
    _ <- Stream.write stream body $ pure unit
    _ <- Stream.end stream $ pure unit
    done $ Either.Right unit
    pure Aff.nonCanceler

-- | Extract the contents of the body of the HTTP `Request`.
read :: HTTP.Request -> Aff.Aff String
read request = Aff.makeAff \done -> do
  let stream = HTTP.requestAsStream request
  buf <- Ref.new ""
  Stream.onDataString stream Encoding.UTF8 \str ->
    void $ Ref.modify ((<>) str) buf
  Stream.onEnd stream $ Ref.read buf >>= Either.Right >>> done
  pure Aff.nonCanceler
