module HTTPure.ResponseSpec where

import Prelude (Unit, discard, ($))
import Test.Spec (Spec, describe, pending)
import Test.Spec.Runner (RunnerEffects)

fromHTTPResponseSpec :: Spec (RunnerEffects ()) Unit
fromHTTPResponseSpec = describe "fromHTTPResponse" $
  pending "wraps an HTTP response"

setStatusCodeSpec :: Spec (RunnerEffects ()) Unit
setStatusCodeSpec = describe "setStatusCode" $
  pending "sets the status code"

writeSpec :: Spec (RunnerEffects ()) Unit
writeSpec = describe "write" $
  pending "adds the string to the response output"

responseSpec :: Spec (RunnerEffects ()) Unit
responseSpec = describe "Response" do
  fromHTTPResponseSpec
  setStatusCodeSpec
  writeSpec
