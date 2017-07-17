module HTTPure.Headers
  ( Headers
  , write
  ) where

import Prelude (Unit, bind, pure, unit, ($))

import Data.Maybe as Maybe
import Data.StrMap as StrMap
import Data.Traversable as Traversable
import Node.HTTP as HTTP

import HTTPure.HTTPureM as HTTPureM

-- | The Headers type is just sugar for a StrMap of Strings that represents the
-- | set of headers sent or received in an HTTP request or response.
type Headers = StrMap.StrMap String

-- | Write a set of headers to the given HTTP Response.
write :: forall e. HTTP.Response -> Headers -> HTTPureM.HTTPureM e Unit
write response headers = do
  _ <- Traversable.traverse writeHeader $ StrMap.keys headers
  pure unit
  where
    getHeader header = Maybe.fromMaybe "" $ StrMap.lookup header headers
    writeHeader header = HTTP.setHeader response header $ getHeader header
