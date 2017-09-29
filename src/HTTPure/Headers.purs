module HTTPure.Headers
  ( Headers
  , empty
  , headers
  , header
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

-- | The `Headers` type is just sugar for a `StrMap` of `Strings` that
-- | represents the set of headers in an HTTP request or response.
newtype Headers = Headers (StrMap.StrMap String)

-- | Given a string, return the value of the matching header, or an empty string
-- | if no match exists. This search is case-insensitive.
instance lookupHeaders :: Lookup.Lookup Headers String String where
  lookup (Headers headers') =
    Maybe.fromMaybe "" <<< flip StrMap.lookup headers' <<< StringUtil.toLower

-- | Allow a `Headers` to be represented as a string. This string is formatted
-- | in HTTP headers format.
instance showHeaders :: Show Headers where
  show (Headers headers') =
    StrMap.foldMap showField headers' <> "\n"
    where
      showField key value = key <> ": " <> value <> "\n"

-- | Compare two `Headers` objects by comparing the underlying `StrMaps`.
instance eqHeaders :: Eq Headers where
  eq (Headers a) (Headers b) = eq a b

-- | Allow one `Headers` objects to be appended to another.
instance semigroupHeaders :: Semigroup Headers where
  append (Headers a) (Headers b) = Headers $ StrMap.union b a

-- | Get the headers out of a HTTP `Request` object.
read :: HTTP.Request -> Headers
read = HTTP.requestHeaders >>> Headers

-- | Given an HTTP `Response` and a `Headers` object, return an effect that will
-- | write the `Headers` to the `Response`.
write :: forall e.
         HTTP.Response ->
         Headers ->
         Eff.Eff (http :: HTTP.HTTP | e) Unit
write response (Headers headers') = void $
  TraversableWithIndex.traverseWithIndex (HTTP.setHeader response) headers'

-- | Return a `Headers` containing nothing.
empty :: Headers
empty = Headers StrMap.empty

-- | Convert an `Array` of `Tuples` of 2 `Strings` to a `Headers` object.
headers :: Array (Tuple.Tuple String String) -> Headers
headers = StrMap.fromFoldable >>> Headers

-- | Create a singleton header from a key-value pair.
header :: String -> String -> Headers
header key = StrMap.singleton key >>> Headers
