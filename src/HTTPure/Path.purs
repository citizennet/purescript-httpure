module HTTPure.Path
  ( Path
  , read
  ) where

import Prelude
import Data.Array as Array
import Data.Maybe as Maybe
import Data.String as String
import Node.HTTP as HTTP
import HTTPure.Utils as Utils

-- | The `Path` type is just sugar for an `Array` of `String` segments that are
-- | sent in a request and indicates the path of the resource being requested.
-- | Note that this type has an implementation of `Lookup` for `Int` keys
-- | defined by `lookupArray` in [Lookup.purs](./Lookup.purs) because
-- | `lookupArray` is defined for any `Array` of `Monoids`. So you can do
-- | something like `path !! 2` to get the path segment at index 2.
type Path
  = Array String

-- | Given an HTTP `Request` object, extract the `Path`.
read :: HTTP.Request -> Path
read = HTTP.requestURL >>> split "?" >>> first >>> split "/" >>> nonempty >>> map Utils.urlDecode
  where
  nonempty = Array.filter ((/=) "")

  split = String.Pattern >>> String.split

  first = Array.head >>> Maybe.fromMaybe ""
