module HTTPure.HTTPureSpec where

import Prelude (Unit, discard, ($))
import Control.Monad.Eff (Eff)
import Test.Spec (describe)
import Test.Spec.Reporter (specReporter)
import Test.Spec.Runner (RunnerEffects, run)

import HTTPure.HTTPureMSpec (httpureMSpec)
import HTTPure.RequestSpec (requestSpec)
import HTTPure.ResponseSpec (responseSpec)
import HTTPure.RouteSpec (routeSpec)
import HTTPure.ServerSpec (serverSpec)
import HTTPure.IntegrationSpec (integrationSpec)

main :: Eff (RunnerEffects ()) Unit
main = run [ specReporter ] $ describe "HTTPure" do
  httpureMSpec
  requestSpec
  responseSpec
  routeSpec
  serverSpec
  integrationSpec
