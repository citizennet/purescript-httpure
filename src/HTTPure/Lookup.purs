module HTTPure.Lookup
  ( class Lookup
  , at
  , (!@)
  , has
  , (!?)
  , lookup
  , (!!)
  ) where

import Prelude
import Data.Array (index)
import Data.Map (Map)
import Data.Map (lookup) as Map
import Data.Maybe (Maybe, fromMaybe, isJust)
import Data.String.CaseInsensitive (CaseInsensitiveString(CaseInsensitiveString))
import Foreign.Object (Object)
import Foreign.Object (lookup) as Object

-- | Types that implement the `Lookup` class can be looked up by some key to
-- | retrieve some value. For instance, you could have an implementation for
-- | `String Int String` where `lookup s i` returns `Just` a `String` containing
-- | the character in `s` at `i`, or `Nothing` if `i` is out of bounds.
class Lookup c k r | c -> r where
  -- | Given some type and a key on that type, extract some value that
  -- | corresponds to that key.
  lookup :: c -> k -> Maybe r

-- | `!!` is inspired by `!!` in `Data.Array`, but note that it differs from
-- | `!!` in `Data.Array` in that you can use `!!` for any other instance of
-- | `Lookup`.
infixl 8 lookup as !!

-- | The instance of `Lookup` for an `Array` is just `!!` as defined in
-- | `Data.Array`.
instance lookupArray :: Lookup (Array t) Int t where
  lookup = index

-- | The instance of `Lookup` for a `Object` just uses `Object.lookup` (but
-- | flipped, because `Object.lookup` expects the key first, which would end up
-- | with a really weird API for `!!`).
instance lookupObject :: Lookup (Object t) String t where
  lookup = flip Object.lookup

-- | The instance of `Lookup` for a `Map CaseInsensitiveString` converts the
-- | `String` to a `CaseInsensitiveString` for lookup.
instance lookupMapCaseInsensitiveString ::
  Lookup (Map CaseInsensitiveString t) String t where
  lookup set key = Map.lookup (CaseInsensitiveString key) set

-- | This simple helper works on any `Lookup` instance where the return type is
-- | a `Monoid`, and is the same as `lookup` except that it returns a `t`
-- | instead of a `Maybe t`. If `lookup` would return `Nothing`, then `at`
-- | returns `mempty`.
at :: forall c k r. Monoid r => Lookup c k r => c -> k -> r
at set = fromMaybe mempty <<< lookup set

-- | Expose `at` as the infix operator `!@`
infixl 8 at as !@

-- | This simple helper works on any `Lookup` instance, where the container set
-- | has a single type variable, and returns a `Boolean` indicating if the given
-- | key matches any value in the given container.
has :: forall c k r. Lookup (c r) k r => c r -> k -> Boolean
has set key = isJust ((lookup set key) :: Maybe r)

-- | Expose `has` as the infix operator `!?`
infixl 8 has as !?
