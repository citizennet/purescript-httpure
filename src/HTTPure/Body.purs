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

import HTTPure.Streamable as Streamable

class Streamable.Streamable b <= Body b where
  size :: b -> Effect.Effect (Maybe.Maybe Int)

instance bodyString :: Body String where
  size s = Buffer.fromString s Encoding.UTF8 >>= size

instance bodyBuffer :: Body Buffer.Buffer where
  size = Buffer.size >>> map Maybe.Just

-- | Extract the contents of the body of the HTTP `Request`.
read :: HTTP.Request -> Aff.Aff String
read request = Aff.makeAff \done -> do
  let stream = HTTP.requestAsStream request
  buf <- Ref.new ""
  Stream.onDataString stream Encoding.UTF8 \str ->
    void $ Ref.modify ((<>) str) buf
  Stream.onEnd stream $ Ref.read buf >>= Either.Right >>> done
  pure Aff.nonCanceler

-- | Write a `Body` to the given HTTP `Response` and close it.
write :: HTTP.Response -> Stream.Readable () -> Aff.Aff Unit
write response body = Aff.makeAff \done -> do
  _ <- Stream.pipe body $ HTTP.responseAsStream response
  Stream.onEnd body $ done $ Either.Right unit
  pure Aff.nonCanceler
