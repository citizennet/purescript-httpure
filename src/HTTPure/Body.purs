module HTTPure.Body
  ( Body
  , read
  , write
  ) where

import Prelude

import Data.Either as Either
import Effect as Effect
import Effect.Aff as Aff
import Effect.Ref as Ref
import Node.Encoding as Encoding
import Node.HTTP as HTTP
import Node.Stream as Stream

-- | The `Body` type is just sugar for a `String`, that will be sent or received
-- | in the HTTP body.
type Body = String

-- | Extract the contents of the body of the HTTP `Request`.
read :: HTTP.Request -> Aff.Aff Body
read request = Aff.makeAff \done -> do
  let stream = HTTP.requestAsStream request
  buf <- Ref.new ""
  Stream.onDataString stream Encoding.UTF8 \str ->
    void $ Ref.modify ((<>) str) buf
  Stream.onEnd stream $ Ref.read buf >>= Either.Right >>> done
  pure $ Aff.nonCanceler

-- | Write a `Body` to the given HTTP `Response` and close it.
write :: HTTP.Response -> Body -> Effect.Effect Unit
write response body = void do
  _ <- Stream.writeString stream Encoding.UTF8 body $ pure unit
  Stream.end stream $ pure unit
  where
    stream = HTTP.responseAsStream response
