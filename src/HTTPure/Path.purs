module HTTPure.Path
  ( Path
  , read
  ) where

import Prelude

import Data.Array (filter, head)
import Data.Maybe (fromMaybe)
import Data.String (Pattern(Pattern), split)
import HTTPure.Utils (urlDecode)
import Node.HTTP (Request, requestURL)

-- | The `Path` type is just sugar for an `Array` of `String` segments that are
-- | sent in a request and indicates the path of the resource being requested.
-- | Note that this type has an implementation of `Lookup` for `Int` keys
-- | defined by `lookupArray` in [Lookup.purs](./Lookup.purs) because
-- | `lookupArray` is defined for any `Array` of `Monoids`. So you can do
-- | something like `path !! 2` to get the path segment at index 2.
type Path = Array String

-- | Given an HTTP `Request` object, extract the `Path`.
read :: Request -> Path
read = requestURL >>> split' "?" >>> first >>> split' "/" >>> nonempty >>> map urlDecode
  where
  nonempty = filter ((/=) "")
  split' = Pattern >>> split
  first = head >>> fromMaybe ""
