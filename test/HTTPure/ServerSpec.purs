module HTTPure.ServerSpec where

import Prelude (Unit, discard, ($))
import Test.Spec (Spec, describe, pending)
import Test.Spec.Runner (RunnerEffects)

handleRequestSpec :: Spec (RunnerEffects ()) Unit
handleRequestSpec = describe "handleRequest" $
  pending "handles the request"

getOptionsSpec :: Spec (RunnerEffects ()) Unit
getOptionsSpec = describe "getOptions" $
  pending "returns an options object"

serveSpec :: Spec (RunnerEffects ()) Unit
serveSpec = describe "serve" $
  pending "starts the server"

serverSpec :: Spec (RunnerEffects ()) Unit
serverSpec = describe "Server" do
  handleRequestSpec
  getOptionsSpec
  serveSpec
