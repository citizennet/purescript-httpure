module HTTPure.Utils
  ( encodeURIComponent
  , decodeURIComponent
  , replacePlus
  , urlDecode
  ) where

import Prelude

import Data.Maybe as Maybe
import Data.Nullable as Nullable
import Data.String as String


foreign import encodeURIComponent :: String -> String

foreign import decodeURIComponentImpl :: String -> Nullable.Nullable String

decodeURIComponent :: String -> Maybe.Maybe String
decodeURIComponent = Nullable.toMaybe <<< decodeURIComponentImpl


replacePlus :: String -> String
replacePlus =
  String.replace (String.Pattern "+") (String.Replacement "%20")


urlDecode :: String -> String
urlDecode s =
  Maybe.fromMaybe s $ decodeURIComponent s
