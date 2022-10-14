module HTTPure.RequestHeaders
  ( RequestHeaders(..)
  , empty
  , read
  ) where

import Prelude

import Data.FoldableWithIndex (foldMapWithIndex)
import Data.Newtype (class Newtype)
import Data.String as String
import Foreign.Object (Object, union)
import Foreign.Object as Object
import HTTPure.Lookup (class Lookup, (!!))
import Node.HTTP (Request, requestHeaders)

-- | The `RequestHeaders` type is just sugar for a `Object` of `Strings`
-- | that represents the set of headers in an HTTP request.
newtype RequestHeaders = RequestHeaders (Object String)

derive instance newtypeRequestHeaders :: Newtype RequestHeaders _

-- | Given a string. return a `Maybe` containing the value of the matching
-- | request header, if there is any.
instance lookupRequestHeaders :: Lookup RequestHeaders String String where
  lookup (RequestHeaders headers') key = headers' !! (String.toLower key)

-- | Allow a `RequestHeaders` to be represented as a string. This string is
-- | formatted in HTTP headers format.
instance showRequestHeaders :: Show RequestHeaders where
  show (RequestHeaders headers') = foldMapWithIndex showField headers' <> "\n"
    where
    showField key value = key <> ": " <> value <> "\n"

-- | Compare two `RequestHeaders` objects by comparing the underlying `Objects`.
derive instance eqRequestHeaders :: Eq RequestHeaders

-- | Allow one `RequestHeaders` objects to be appended to another.
instance semigroupRequestHeaders :: Semigroup RequestHeaders where
  append (RequestHeaders a) (RequestHeaders b) = RequestHeaders $ union b a

-- | Get the request headers out of a HTTP `Request` object.
read :: Request -> RequestHeaders
read = requestHeaders >>> RequestHeaders

empty :: RequestHeaders
empty = RequestHeaders Object.empty
