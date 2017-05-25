module HTTPure.IntegrationSpec where

import Prelude (Unit, ($))
import Test.Spec (Spec, describe, pending)
import Test.Spec.Runner (RunnerEffects)

startsServerSpec :: Spec (RunnerEffects ()) Unit
startsServerSpec =
  pending "starts a server"

integrationSpec :: Spec (RunnerEffects ()) Unit
integrationSpec = describe "integration" $
  startsServerSpec
