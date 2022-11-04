module HTTPure.Headers
  ( Headers(..)
  , empty
  , headers
  , header
  , read
  , write
  ) where

import Prelude

import Data.Foldable (foldl)
import Data.Generic.Rep (class Generic)
import Data.Map (Map, insert, singleton, union)
import Data.Map (empty) as Map
import Data.Newtype (class Newtype, unwrap)
import Data.Show.Generic (genericShow)
import Data.String.CaseInsensitive (CaseInsensitiveString(CaseInsensitiveString))
import Data.TraversableWithIndex (traverseWithIndex)
import Data.Tuple (Tuple(Tuple))
import Effect (Effect)
import Foreign.Object (fold)
import HTTPure.Lookup (class Lookup, (!!))
import Node.HTTP (Request, Response, requestHeaders, setHeader)

-- | The `Headers` type is just sugar for a `Object` of `Strings`
-- | that represents the set of headers in an HTTP request or response.
newtype Headers = Headers (Map CaseInsensitiveString String)

derive instance newtypeHeaders :: Newtype Headers _

derive instance genericHeaders :: Generic Headers _

-- | Given a string, return a `Maybe` containing the value of the matching
-- | header, if there is any.
instance lookupHeaders :: Lookup Headers String String where
  lookup (Headers headers') key = headers' !! key

instance showHeaders :: Show Headers where
  show = genericShow

-- | Compare two `Headers` objects by comparing the underlying `Objects`.
derive newtype instance eqHeaders :: Eq Headers

-- | Allow one `Headers` objects to be appended to another.
instance semigroupHeaders :: Semigroup Headers where
  append (Headers a) (Headers b) = Headers $ union b a

-- | Get the headers out of a HTTP `Request` object.
read :: Request -> Headers
read = requestHeaders >>> fold insertField Map.empty >>> Headers
  where
  insertField x key value = insert (CaseInsensitiveString key) value x

-- | Given an HTTP `Response` and a `Headers` object, return an effect that will
-- | write the `Headers` to the `Response`.
write :: Response -> Headers -> Effect Unit
write response (Headers headers') = void $ traverseWithIndex writeField headers'
  where
  writeField key value = setHeader response (unwrap key) value

-- | Return a `Headers` containing nothing.
empty :: Headers
empty = Headers Map.empty

-- | Convert an `Array` of `Tuples` of 2 `Strings` to a `Headers` object.
headers :: Array (Tuple String String) -> Headers
headers = foldl insertField Map.empty >>> Headers
  where
  insertField x (Tuple key value) = insert (CaseInsensitiveString key) value x

-- | Create a singleton header from a key-value pair.
header :: String -> String -> Headers
header key = singleton (CaseInsensitiveString key) >>> Headers
