module HTTPure.Headers
  ( Headers
  , lookup
  , write
  ) where

import Prelude (Unit, bind, flip, pure, unit, ($), (<<<))

import Data.Maybe as Maybe
import Data.String as StringUtil
import Data.StrMap as StrMap
import Data.Traversable as Traversable
import Node.HTTP as HTTP

import HTTPure.HTTPureM as HTTPureM

-- | The Headers type is just sugar for a StrMap of Strings that represents the
-- | set of headers sent or received in an HTTP request or response.
type Headers = StrMap.StrMap String

-- | Return the value of the given header.
lookup :: Headers -> String -> String
lookup headers =
  Maybe.fromMaybe "" <<< flip StrMap.lookup headers <<< StringUtil.toLower

-- | Write a set of headers to the given HTTP Response.
write :: forall e. HTTP.Response -> Headers -> HTTPureM.HTTPureM e Unit
write response headers = do
  _ <- Traversable.traverse writeHeader $ StrMap.keys headers
  pure unit
  where
    getHeader header = Maybe.fromMaybe "" $ StrMap.lookup header headers
    writeHeader header = HTTP.setHeader response header $ getHeader header
