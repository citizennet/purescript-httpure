module HTTPure.Utils
  ( encodeURIComponent
  , replacePlus
  , urlDecode
  ) where

import Prelude
import Data.Maybe as Maybe
import Data.String as String
import JSURI as JSURI

encodeURIComponent :: String -> String
encodeURIComponent s = Maybe.fromMaybe s $ JSURI.encodeURIComponent s

replacePlus :: String -> String
replacePlus = String.replaceAll (String.Pattern "+") (String.Replacement "%20")

urlDecode :: String -> String
urlDecode s = Maybe.fromMaybe s $ JSURI.decodeURIComponent s
