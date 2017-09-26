module HTTPure.Lookup
  ( class Lookup
  , lookup, (!!)
  ) where

import Prelude

import Data.Array as Array
import Data.Maybe as Maybe
import Data.Monoid as Monoid
import Data.StrMap as StrMap

-- | Types that implement the `Lookup` class can be looked up by some key to
-- | retrieve some value. For instance, you could have an implementation for
-- | `String (Maybe String) Int` where `lookup s i` returns `Just` the
-- | character in `s` at `i`, or `Nothing` if `i` is out of bounds.
class Lookup a v k where

  -- | Given some type and a key on that type, extract some value that
  -- | corresponds to that key.
  lookup :: a -> k -> v

-- | `!!` is inspired by `!!` in `Data.Array`, but note that it differs from
-- | `!!` in `Data.Array` in that the default instance for `Arrays` with `Int`
-- | key types is defined on `Arrays` of some members of `Monoids`, and will
-- | always return a value and will not return `Maybes`. If the requested index
-- | is out of bounds, then this implementation will return `mempty` instead of
-- | `Nothing`.
infixl 8 lookup as !!

-- | A default instance of `Lookup` for an `Array` of some type of `Monoid`.
-- | Note that this is different from `!!` defined in `Data.Array` in that it
-- | does not return a `Maybe`. If the index is out of bounds, the return value
-- | is `mempty`.
instance lookupArray :: Monoid.Monoid m => Lookup (Array m) m Int where
  lookup arr = Maybe.fromMaybe Monoid.mempty <<< Array.index arr

-- | A default instance of `Lookup` for a `StrMap` of some type of `Monoid`. If
-- | the key does not exist in the `StrMap`, then the return value is `mempty`.
instance lookupStrMap :: Monoid.Monoid m =>
                         Lookup (StrMap.StrMap m) m String where
  lookup strMap = Maybe.fromMaybe Monoid.mempty <<< flip StrMap.lookup strMap
