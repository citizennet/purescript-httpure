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

class Body b where
  size :: b -> Effect.Effect (Maybe.Maybe Int)
  write :: b -> HTTP.Response -> Aff.Aff Unit

instance bodyString :: Body String where
  size body = Buffer.fromString body Encoding.UTF8 >>= size
  write body response = Aff.makeAff \done -> do
    _ <- Stream.writeString stream Encoding.UTF8 body $ pure unit
    _ <- Stream.end stream $ pure unit
    done $ Either.Right unit
    pure Aff.nonCanceler
    where
      stream = HTTP.responseAsStream response

instance bodyBuffer :: Body Buffer.Buffer where
  size = Buffer.size >>> map Maybe.Just
  write body response = Aff.makeAff \done -> do
    _ <- Stream.write stream body $ pure unit
    _ <- Stream.end stream $ pure unit
    done $ Either.Right unit
    pure Aff.nonCanceler
    where
      stream = HTTP.responseAsStream response

-- | Extract the contents of the body of the HTTP `Request`.
read :: HTTP.Request -> Aff.Aff String
read request = Aff.makeAff \done -> do
  let stream = HTTP.requestAsStream request
  buf <- Ref.new ""
  Stream.onDataString stream Encoding.UTF8 \str ->
    void $ Ref.modify ((<>) str) buf
  Stream.onEnd stream $ Ref.read buf >>= Either.Right >>> done
  pure Aff.nonCanceler
