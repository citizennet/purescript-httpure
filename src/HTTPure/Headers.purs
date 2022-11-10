module HTTPure.Headers
  ( Headers(..)
  , empty
  , headers
  , header
  , read
  , toString
  , write
  ) where

import Prelude

import Data.Foldable (foldMap)
import Data.FoldableWithIndex (foldMapWithIndex)
import Data.Generic.Rep (class Generic)
import Data.Map (Map, singleton, union)
import Data.Map (empty) as Map
import Data.Newtype (class Newtype, unwrap)
import Data.Show.Generic (genericShow)
import Data.String as Data.String
import Data.String.CaseInsensitive (CaseInsensitiveString(CaseInsensitiveString))
import Data.TraversableWithIndex (traverseWithIndex)
import Data.Tuple (Tuple, uncurry)
import Effect (Effect)
import Foreign.Object as Foreign.Object
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

instance monoidHeaders :: Monoid Headers where
  mempty = Headers Map.empty

-- | Get the headers out of a HTTP `Request` object.
-- |
-- | We intentionally filter out "Set-Cookie" headers here as according to the
-- | node.js docs, the "set-cookie" header is always represented as an array,
-- | and trying to read it as `String` would cause a runtime type error.
-- | See https://nodejs.org/api/http.html#messageheaders.
read :: Request -> Headers
read = Foreign.Object.foldMap header' <<< requestHeaders
  where
  header' :: String -> String -> Headers
  header' key
    | Data.String.toLower key == "set-cookie" = const mempty
    | otherwise = header key

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
headers = foldMap (uncurry header)

-- | Create a singleton header from a key-value pair.
header :: String -> String -> Headers
header key = singleton (CaseInsensitiveString key) >>> Headers

-- | Allow a `Headers` to be represented as a string. This string is formatted
-- | in HTTP headers format.
toString :: Headers -> String
toString (Headers headersMap) = foldMapWithIndex showField headersMap <> "\n"
  where
  showField :: CaseInsensitiveString -> String -> String
  showField key value = unwrap key <> ": " <> value <> "\n"
