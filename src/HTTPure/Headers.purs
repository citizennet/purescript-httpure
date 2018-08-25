module HTTPure.Headers
  ( Headers(..)
  , empty
  , headers
  , header
  , read
  , write
  ) where

import Prelude

import Effect as Effect
import Foreign.Object as Object
import Data.Newtype as Newtype
import Data.String as String
import Data.TraversableWithIndex as TraversableWithIndex
import Data.Tuple as Tuple
import Node.HTTP as HTTP

import HTTPure.Lookup as Lookup
import HTTPure.Lookup ((!!))

-- | The `Headers` type is just sugar for a `Object` of `Strings`
-- | that represents the set of headers in an HTTP request or response.
newtype Headers = Headers (Object.Object String)
derive instance newtypeHeaders :: Newtype.Newtype Headers _

-- | Given a string, return a `Maybe` containing the value of the matching
-- | header, if there is any.
instance lookup :: Lookup.Lookup Headers String String where
  lookup (Headers headers') key = headers' !! String.toLower key

-- | Allow a `Headers` to be represented as a string. This string is formatted
-- | in HTTP headers format.
instance show :: Show Headers where
  show (Headers headers') =
    Object.foldMap showField headers' <> "\n"
    where
      showField key value = key <> ": " <> value <> "\n"

-- | Compare two `Headers` objects by comparing the underlying `Objects`.
instance eq :: Eq Headers where
  eq (Headers a) (Headers b) = eq a b

-- | Allow one `Headers` objects to be appended to another.
instance semigroup :: Semigroup Headers where
  append (Headers a) (Headers b) = Headers $ Object.union b a

-- | Get the headers out of a HTTP `Request` object.
read :: HTTP.Request -> Headers
read = HTTP.requestHeaders >>> Headers

-- | Given an HTTP `Response` and a `Headers` object, return an effect that will
-- | write the `Headers` to the `Response`.
write :: HTTP.Response -> Headers -> Effect.Effect Unit
write response (Headers headers') = void $
  TraversableWithIndex.traverseWithIndex (HTTP.setHeader response) headers'

-- | Return a `Headers` containing nothing.
empty :: Headers
empty = Headers Object.empty

-- | Convert an `Array` of `Tuples` of 2 `Strings` to a `Headers` object.
headers :: Array (Tuple.Tuple String String) -> Headers
headers = Object.fromFoldable >>> Headers

-- | Create a singleton header from a key-value pair.
header :: String -> String -> Headers
header key = Object.singleton key >>> Headers
