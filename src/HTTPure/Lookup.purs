module HTTPure.Lookup
  ( class Lookup
  , at, (!@)
  , has, (!?)
  , lookup, (!!)
  ) where

import Prelude

import Data.Array as Array
import Data.Maybe as Maybe
import Data.Monoid as Monoid
import Data.StrMap as StrMap

-- | Types that implement the `Lookup` class can be looked up by some key to
-- | retrieve some value. For instance, you could have an implementation for
-- | `String Int String` where `lookup s i` returns `Just` a `String` containing
-- | the character in `s` at `i`, or `Nothing` if `i` is out of bounds.
class Lookup c k r where

  -- | Given some type and a key on that type, extract some value that
  -- | corresponds to that key.
  lookup :: c -> k -> Maybe.Maybe r

-- | `!!` is inspired by `!!` in `Data.Array`, but note that it differs from
-- | `!!` in `Data.Array` in that you can use `!!` for any other instance of
-- | `Lookup`.
infixl 8 lookup as !!

-- | The instance of `Lookup` for an `Array` is just `!!` as defined in
-- | `Data.Array`.
instance lookupArray :: Lookup (Array t) Int t where
  lookup = Array.index

-- | The instance of `Lookup` for a `StrMap` just uses `StrMap.lookup` (but
-- | flipped, because `StrMap.lookup` expects the key first, which would end up
-- | with a really weird API for `!!`).
instance lookupStrMap :: Lookup (StrMap.StrMap t) String t where
  lookup = flip StrMap.lookup

-- | This simple helper works on any `Lookup` instance where the return type is
-- | a `Monoid`, and is the same as `lookup` except that it returns a `t`
-- | instead of a `Maybe t`. If `lookup` would return `Nothing`, then `at`
-- | returns `mempty`.
at :: forall c k r. Monoid.Monoid r => Lookup c k r => c -> k -> r
at set = Maybe.fromMaybe Monoid.mempty <<< lookup set

-- | Expose `at` as the infix operator `!@`
infixl 8 at as !@

-- | This simple helper works on any `Lookup` instance, where the container set
-- | has a single type variable, and returns a `Boolean` indicating if the given
-- | key matches any value in the given container.
has :: forall c k r. Lookup (c r) k r => c r -> k -> Boolean
has set key = Maybe.isJust ((lookup set key) :: Maybe.Maybe r)

-- | Expose `has` as the infix operator `!?`
infixl 8 has as !?
