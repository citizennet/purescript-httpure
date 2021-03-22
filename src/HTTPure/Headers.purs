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
import Data.Foldable as Foldable
import Data.FoldableWithIndex as FoldableWithIndex
import Data.Map as Map
import Data.Newtype as Newtype
import Data.String.CaseInsensitive as CaseInsensitive
import Data.TraversableWithIndex as TraversableWithIndex
import Data.Tuple as Tuple
import Node.HTTP as HTTP
import HTTPure.Lookup as Lookup
import HTTPure.Lookup ((!!))

-- | The `Headers` type is just sugar for a `Object` of `Strings`
-- | that represents the set of headers in an HTTP request or response.
newtype Headers
  = Headers (Map.Map CaseInsensitive.CaseInsensitiveString String)

derive instance newtypeHeaders :: Newtype.Newtype Headers _

-- | Given a string, return a `Maybe` containing the value of the matching
-- | header, if there is any.
instance lookup :: Lookup.Lookup Headers String String where
  lookup (Headers headers') key = headers' !! key

-- | Allow a `Headers` to be represented as a string. This string is formatted
-- | in HTTP headers format.
instance show :: Show Headers where
  show (Headers headers') = FoldableWithIndex.foldMapWithIndex showField headers' <> "\n"
    where
    showField key value = Newtype.unwrap key <> ": " <> value <> "\n"

-- | Compare two `Headers` objects by comparing the underlying `Objects`.
instance eq :: Eq Headers where
  eq (Headers a) (Headers b) = eq a b

-- | Allow one `Headers` objects to be appended to another.
instance semigroup :: Semigroup Headers where
  append (Headers a) (Headers b) = Headers $ Map.union b a

-- | Get the headers out of a HTTP `Request` object.
read :: HTTP.Request -> Headers
read = HTTP.requestHeaders >>> Object.fold insertField Map.empty >>> Headers
  where
  insertField x key value = Map.insert (CaseInsensitive.CaseInsensitiveString key) value x

-- | Given an HTTP `Response` and a `Headers` object, return an effect that will
-- | write the `Headers` to the `Response`.
write :: HTTP.Response -> Headers -> Effect.Effect Unit
write response (Headers headers') =
  void
    $ TraversableWithIndex.traverseWithIndex writeField headers'
  where
  writeField key value = HTTP.setHeader response (Newtype.unwrap key) value

-- | Return a `Headers` containing nothing.
empty :: Headers
empty = Headers Map.empty

-- | Convert an `Array` of `Tuples` of 2 `Strings` to a `Headers` object.
headers :: Array (Tuple.Tuple String String) -> Headers
headers = Foldable.foldl insertField Map.empty >>> Headers
  where
  insertField x (Tuple.Tuple key value) = Map.insert (CaseInsensitive.CaseInsensitiveString key) value x

-- | Create a singleton header from a key-value pair.
header :: String -> String -> Headers
header key = Map.singleton (CaseInsensitive.CaseInsensitiveString key) >>> Headers
