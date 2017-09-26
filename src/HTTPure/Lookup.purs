module HTTPure.Lookup
  ( class Lookup
  , lookup, (!!)
  ) where

import Prelude

import Data.Array as Array
import Data.Maybe as Maybe
import Data.Monoid as Monoid

-- | Types that implement the Lookup class can be looked up by some key to
-- | retrieve some value. For instance, you could have an implementation for
-- | String (Maybe String) Int where `lookup string index` returns `Just` the
-- | character in `string` at `index`, or `Nothing` if `index` is out of bounds.
class Lookup a v k where
  lookup :: a -> k -> v

-- | !! can be used as an infix operator instead of using the `lookup` function.
infixl 8 lookup as !!

-- | A default instance of Lookup for an Array of some type of Monoid. Note that
-- | this is different from `!!` defined in `Data.Array` in that it does not
-- | return a Maybe. If the index is out of bounds, the return value is mempty.
instance lookupArray :: Monoid.Monoid m => Lookup (Array m) m Int where
  lookup arr = Maybe.fromMaybe Monoid.mempty <<< Array.index arr
