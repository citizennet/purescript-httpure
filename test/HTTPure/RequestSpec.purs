module HTTPure.RequestSpec where

import Prelude (Unit, discard, ($))
import Test.Spec (Spec, describe, pending)
import Test.Spec.Runner (RunnerEffects)

fromHTTPRequestSpec :: Spec (RunnerEffects ()) Unit
fromHTTPRequestSpec = describe "fromHTTPRequest" $
  pending "wraps an HTTP request"

getURLSpec :: Spec (RunnerEffects ()) Unit
getURLSpec = describe "getURL" $
  pending "returns the URL of the request"

requestSpec :: Spec (RunnerEffects ()) Unit
requestSpec = describe "Request" do
  fromHTTPRequestSpec
  getURLSpec
