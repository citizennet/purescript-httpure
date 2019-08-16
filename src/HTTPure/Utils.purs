module HTTPure.Utils
  ( module Global
  , encodeURIComponent
  , replacePlus
  , urlDecode
  ) where

import Prelude

import Data.Maybe as Maybe
import Data.String as String
import Global (decodeURIComponent) as Global
import Global.Unsafe (unsafeEncodeURIComponent)


encodeURIComponent :: String -> String
encodeURIComponent = unsafeEncodeURIComponent


replacePlus :: String -> String
replacePlus =
  String.replace (String.Pattern "+") (String.Replacement "%20")


urlDecode :: String -> String
urlDecode s =
  Maybe.fromMaybe s $ Global.decodeURIComponent s
