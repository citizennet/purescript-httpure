module HTTPure.MultiHeaders
  ( MultiHeaders(..)
  , empty
  , fromHeaders
  , header
  , header'
  , headers
  , headers'
  , read
  , toString
  , write
  ) where

import Prelude

import Data.Array.NonEmpty (NonEmptyArray)
import Data.Array.NonEmpty as Data.Array.NonEmpty
import Data.Foldable as Data.Foldable
import Data.FoldableWithIndex as Data.FoldableWithIndex
import Data.Generic.Rep (class Generic)
import Data.Map (Map)
import Data.Map as Data.Map
import Data.Newtype (class Newtype, un)
import Data.Show.Generic as Data.Show.Generic
import Data.String.CaseInsensitive (CaseInsensitiveString(..))
import Data.TraversableWithIndex as Data.TraversableWithIndex
import Data.Tuple (Tuple(..))
import Effect (Effect)
import HTTPure.Headers (Headers(..))
import HTTPure.Lookup (class Lookup, (!!))
import Node.HTTP as Node.HTTP
import Unsafe.Coerce as Unsafe.Coerce

-- | The `MultiHeaders` type represets the set of headers in a HTTP request or
-- | response read in a way such that every header name maps to a non-empty list
-- | of header values. This is useful for headers that may have multiple values,
-- | such as "Set-Cookie".
newtype MultiHeaders = MultiHeaders (Map CaseInsensitiveString (NonEmptyArray String))

derive instance newtypeMultiHeaders :: Newtype MultiHeaders _

derive instance genericMultiHeaders :: Generic MultiHeaders _

-- | Given a string, return a `Maybe` containing the values of the matching
-- | header, if there is any.
instance lookupMultiHeaders :: Lookup MultiHeaders String (NonEmptyArray String) where
  lookup (MultiHeaders headersMap) key = headersMap !! key

instance showMultiHeaders :: Show MultiHeaders where
  show = Data.Show.Generic.genericShow

-- | Compare two `MultiHeaders` objects by comparing the underlying `Objects`.
derive newtype instance eqMultiHeaders :: Eq MultiHeaders

-- | Allow one `MultiHeaders` objects to be appended to another.
instance semigroupMultiHeaders :: Semigroup MultiHeaders where
  append (MultiHeaders a) (MultiHeaders b) =
    MultiHeaders $ Data.Map.unionWith append a b

instance monoidMultiHeaders :: Monoid MultiHeaders where
  mempty = MultiHeaders Data.Map.empty

-- | Return a `MultiHeaders` containing nothing.
empty :: MultiHeaders
empty = MultiHeaders Data.Map.empty

-- | Create a `MultiHeaders` out of a `Headers` value.
fromHeaders :: Headers -> MultiHeaders
fromHeaders = MultiHeaders <<< map pure <<< Data.Map.fromFoldableWithIndex <<< un Headers

-- | Create a singleton header from a key-value pair.
header :: String -> String -> MultiHeaders
header key = header' key <<< Data.Array.NonEmpty.singleton

-- | Create a singleton header from a key-values pair.
header' :: String -> NonEmptyArray String -> MultiHeaders
header' key = MultiHeaders <<< Data.Map.singleton (CaseInsensitiveString key)

-- | Convert an `Array` of `Tuples` of 2 `Strings` to a `MultiHeaders` object.
headers :: Array (Tuple String String) -> MultiHeaders
headers = headers' <<< map (map pure)

-- | Convert an `Array` of `Tuples` of 2 `Strings` to a `MultiHeaders` object.
headers' :: Array (Tuple String (NonEmptyArray String)) -> MultiHeaders
headers' = MultiHeaders <<< Data.Foldable.foldl insertField Data.Map.empty
  where
  insertField x (Tuple key values) = Data.Map.insertWith append (CaseInsensitiveString key) values x

-- | Parse a list of raw request headers, applying the given function to every
-- | key-value pair.
-- | See https://nodejs.org/api/http.html#messagerawheaders.
foreign import parseRawHeaders :: forall a. (String -> String -> a) -> Array String -> Array a

-- | Read the headers out of a HTTP `Request` object and parse duplicated
-- | headers as a list (instead of comma-separated values, as with
-- | `HTTPure.Headers.read`).
read :: Node.HTTP.Request -> MultiHeaders
read =
  MultiHeaders
    <<< Data.Map.fromFoldableWith (flip append)
    <<< map (\(Tuple key value) -> Tuple (CaseInsensitiveString key) (pure value))
    <<< parseRawHeaders Tuple
    <<< requestRawHeaders
  where
  -- | The raw request/response headers list exactly as they were received.
  -- | The keys and values are in the same list. It is not a list of tuples.
  -- | So, the even-numbered offsets are key values, and the odd-numbered
  -- | offsets are the associated values. Header names are not lowercased, and
  -- | duplicates are not merged.
  -- | See https://nodejs.org/api/http.html#messagerawheaders.
  requestRawHeaders :: Node.HTTP.Request -> Array String
  requestRawHeaders = _.rawHeaders <<< Unsafe.Coerce.unsafeCoerce

-- | Allow a `MultiHeaders` to be represented as a string. This string is
-- | formatted in HTTP headers format.
toString :: MultiHeaders -> String
toString (MultiHeaders headersMap) = Data.FoldableWithIndex.foldMapWithIndex showField headersMap <> "\n"
  where
  showField :: CaseInsensitiveString -> NonEmptyArray String -> String
  showField key values =
    let
      separator :: String
      separator = if key == CaseInsensitiveString "Set-Cookie" then "; " else ", "
    in
      un CaseInsensitiveString key <> ": " <> Data.Foldable.intercalate separator values <> "\n"

-- | Given an HTTP `Response` and a `MultiHeaders` object, return an effect that will
-- | write the `MultiHeaders` to the `Response`.
write :: Node.HTTP.Response -> MultiHeaders -> Effect Unit
write response (MultiHeaders headersMap) = void $ Data.TraversableWithIndex.traverseWithIndex writeField headersMap
  where
  writeField :: CaseInsensitiveString -> NonEmptyArray String -> Effect Unit
  writeField key = Node.HTTP.setHeaders response (un CaseInsensitiveString key) <<< Data.Array.NonEmpty.toArray
