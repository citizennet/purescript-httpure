module HTTPure.Query
  ( Query
  , read
  ) where

import Prelude
import Data.Array (filter, head, tail)
import Data.Bifunctor (bimap)
import Data.Maybe (fromMaybe)
import Data.String (Pattern(Pattern), split, joinWith)
import Data.Tuple (Tuple(Tuple))
import Foreign.Object (Object, fromFoldable)
import Node.HTTP (Request, requestURL)
import HTTPure.Utils (replacePlus, urlDecode)

-- | The `Query` type is a `Object` of `Strings`, with one entry per query
-- | parameter in the request. For any query parameters that don't have values
-- | (`/some/path?query` or `/some/path?query=`), the value in the `Object` for
-- | that parameter will be the an empty string. Note that this type has an
-- | implementation of `Lookup` for `String` keys defined by `lookupObject` in
-- | [Lookup.purs](./Lookup.purs) because `lookupObject` is defined for any
-- | `Object` of `Monoids`. So you can do something like `query !! "foo"` to get
-- | the value of the query parameter "foo".
type Query = Object String

-- | The `Map` of query segments in the given HTTP `Request`.
read :: Request -> Query
read = requestURL >>> split' "?" >>> last >>> split' "&" >>> nonempty >>> toObject
  where
  toObject = map toTuple >>> fromFoldable
  nonempty = filter ((/=) "")
  split' = Pattern >>> split
  first = head >>> fromMaybe ""
  last = tail >>> fromMaybe [] >>> joinWith ""
  decode = replacePlus >>> urlDecode
  decodeKeyValue = bimap decode decode
  toTuple item = decodeKeyValue $ Tuple (first itemParts) (last itemParts)
    where
    itemParts = split' "=" item
