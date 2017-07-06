module HTTPure.HTTPureSpec where

import Prelude (discard, ($))

import Test.Spec as Spec
import Test.Spec.Reporter as Reporter
import Test.Spec.Runner as Runner

import HTTPure.HTTPureMSpec as HTTPureMSpec
import HTTPure.RequestSpec as RequestSpec
import HTTPure.ResponseSpec as ResponseSpec
import HTTPure.RouteSpec as RouteSpec
import HTTPure.ServerSpec as ServerSpec
import HTTPure.SpecHelpers as SpecHelpers
import HTTPure.IntegrationSpec as IntegrationSpec

main :: SpecHelpers.TestSuite
main = Runner.run [ Reporter.specReporter ] $ Spec.describe "HTTPure" do
  HTTPureMSpec.httpureMSpec
  RequestSpec.requestSpec
  ResponseSpec.responseSpec
  RouteSpec.routeSpec
  ServerSpec.serverSpec
  IntegrationSpec.integrationSpec
