module HTTPure.RequestHeaders
  ( RequestHeaders(..)
  , empty
  , header
  , headers
  , read
  , toString
  ) where

import Prelude

import Data.Bifunctor (lmap)
import Data.Foldable (foldl)
import Data.FoldableWithIndex (foldMapWithIndex)
import Data.Generic.Rep (class Generic)
import Data.Map (Map)
import Data.Map as Data.Map
import Data.Newtype (class Newtype, un)
import Data.Show.Generic (genericShow)
import Data.String as String
import Data.String.CaseInsensitive (CaseInsensitiveString(..))
import Data.Tuple (Tuple(..))
import Foreign.Object as Object
import HTTPure.Lookup (class Lookup, (!!))
import Node.HTTP (Request, requestHeaders)

-- | The `RequestHeaders` type is just sugar for a `Object` of `Strings`
-- | that represents the set of headers in an HTTP request.
newtype RequestHeaders = RequestHeaders (Map CaseInsensitiveString String)

derive instance newtypeRequestHeaders :: Newtype RequestHeaders _

derive instance genericRequestHeaders :: Generic RequestHeaders _

-- | Given a string. return a `Maybe` containing the value of the matching
-- | request header, if there is any.
instance lookupRequestHeaders :: Lookup RequestHeaders String String where
  lookup (RequestHeaders headers') key = headers' !! (String.toLower key)

instance showRequestHeaders :: Show RequestHeaders where
  show = genericShow

-- | Compare two `RequestHeaders` objects by comparing the underlying `Objects`.
derive instance eqRequestHeaders :: Eq RequestHeaders

-- | Allow one `RequestHeaders` objects to be appended to another.
instance semigroupRequestHeaders :: Semigroup RequestHeaders where
  append (RequestHeaders a) (RequestHeaders b) = RequestHeaders $ Data.Map.union b a

-- | Create a singleton header from a key-value pair.
header :: String -> String -> RequestHeaders
header key = Data.Map.singleton (CaseInsensitiveString key) >>> RequestHeaders

-- | Convert an `Array` of `Tuples` of 2 `Strings` to a `RequestHeaders`
-- | object.
headers :: Array (Tuple String String) -> RequestHeaders
headers = foldl insertField Data.Map.empty >>> RequestHeaders
  where
  insertField x (Tuple key value) = Data.Map.insert (CaseInsensitiveString key) value x

-- | Get the request headers out of a HTTP `Request` object.
read :: Request -> RequestHeaders
read =
  RequestHeaders
    <<< Data.Map.fromFoldable
    <<< map (lmap CaseInsensitiveString)
    <<< (Object.toUnfoldable :: _ -> Array _)
    <<< requestHeaders

empty :: RequestHeaders
empty = RequestHeaders Data.Map.empty

-- | Allow a `RequestHeaders` to be represented as a string. This string is
-- | formatted in HTTP headers format.
toString :: RequestHeaders -> String
toString (RequestHeaders headers') = foldMapWithIndex showField headers' <> "\n"
  where
  showField key value = un CaseInsensitiveString key <> ": " <> value <> "\n"
