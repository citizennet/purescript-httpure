module HTTPure.Headers
  ( Headers
  , headers
  , read
  , write
  ) where

import Prelude

import Control.Monad.Eff as Eff
import Data.Maybe as Maybe
import Data.String as StringUtil
import Data.StrMap as StrMap
import Data.TraversableWithIndex as TraversableWithIndex
import Data.Tuple as Tuple
import Node.HTTP as HTTP

import HTTPure.Lookup as Lookup

-- | The Headers type is just sugar for a StrMap of Strings that represents the
-- | set of headers sent or received in an HTTP request or response.
newtype Headers = Headers (StrMap.StrMap String)

-- | Given a string, return the matching headers. This search is
-- | case-insensitive.
instance lookupHeaders :: Lookup.Lookup Headers String String where
  lookup (Headers headers') =
    Maybe.fromMaybe "" <<< flip StrMap.lookup headers' <<< StringUtil.toLower

-- | Allow a headers set to be represented as a string.
instance showHeaders :: Show Headers where
  show (Headers headers') =
    StrMap.foldMap showField headers' <> "\n"
    where
      showField key value = key <> ": " <> value <> "\n"

-- | Compare two Headers objects by comparing the underlying StrMaps.
instance eqHeaders :: Eq Headers where
  eq (Headers a) (Headers b) = eq a b

-- | Get the headers out of a HTTP Request object.
read :: HTTP.Request -> Headers
read = HTTP.requestHeaders >>> Headers

-- | Given an HTTP Response and a Headers object, return an effect that will
-- | write the Headers to the Response.
write :: forall e.
         HTTP.Response ->
         Headers ->
         Eff.Eff (http :: HTTP.HTTP | e) Unit
write response (Headers headers') = void $
  TraversableWithIndex.traverseWithIndex (HTTP.setHeader response) headers'

-- | Convert an Array of Tuples of 2 Strings to a Headers object.
headers :: Array (Tuple.Tuple String String) -> Headers
headers = StrMap.fromFoldable >>> Headers
