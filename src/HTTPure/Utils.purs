module HTTPure.Utils
  ( encodeURIComponent
  , replacePlus
  , urlDecode
  ) where

import Prelude
import Data.Maybe (fromMaybe)
import Data.String (Pattern(Pattern), Replacement(Replacement), replaceAll)
import JSURI (encodeURIComponent, decodeURIComponent) as JSURI

encodeURIComponent :: String -> String
encodeURIComponent s = fromMaybe s $ JSURI.encodeURIComponent s

replacePlus :: String -> String
replacePlus = replaceAll (Pattern "+") (Replacement "%20")

urlDecode :: String -> String
urlDecode s = fromMaybe s $ JSURI.decodeURIComponent s
