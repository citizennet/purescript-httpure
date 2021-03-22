module Test.HTTPure.UtilsSpec where

import Prelude
import Data.Tuple as Tuple
import Foreign.Object as Object
import Test.Spec as Spec
import HTTPure.Query as Query
import HTTPure.Utils as Utils
import Test.HTTPure.TestHelpers as TestHelpers
import Test.HTTPure.TestHelpers ((?=))

utilsSpec :: TestHelpers.Test
utilsSpec =
  Spec.describe "replacePlus" do
    Spec.it "should replace all pluses" do
      Utils.replacePlus "HTTPPure+is+A+purescript+HTTP+server+framework"
        ?= "HTTPPure%20is%20A%20purescript%20HTTP%20server%20framework"
