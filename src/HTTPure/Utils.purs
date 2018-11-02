module HTTPure.Utils
  ( encodeURIComponent
  , decodeURIComponent
  ) where

import Prelude

import Data.Maybe as Maybe
import Data.Nullable as Nullable


foreign import encodeURIComponent :: String -> String

foreign import decodeURIComponentImpl :: String -> Nullable.Nullable String

decodeURIComponent :: String -> Maybe.Maybe String
decodeURIComponent = Nullable.toMaybe <<< decodeURIComponentImpl
