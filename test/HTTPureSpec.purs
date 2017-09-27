module HTTPure.HTTPureSpec where

import Prelude

import Test.Spec as Spec
import Test.Spec.Reporter as Reporter
import Test.Spec.Runner as Runner

import HTTPure.BodySpec as BodySpec
import HTTPure.HeadersSpec as HeadersSpec
import HTTPure.HTTPureEffectsSpec as HTTPureEffectsSpec
import HTTPure.LookupSpec as LookupSpec
import HTTPure.MethodSpec as MethodSpec
import HTTPure.PathSpec as PathSpec
import HTTPure.QuerySpec as QuerySpec
import HTTPure.RequestSpec as RequestSpec
import HTTPure.ResponseSpec as ResponseSpec
import HTTPure.ServerSpec as ServerSpec
import HTTPure.StatusSpec as StatusSpec
import HTTPure.IntegrationSpec as IntegrationSpec

import HTTPure.SpecHelpers as SpecHelpers

main :: SpecHelpers.TestSuite
main = Runner.run [ Reporter.specReporter ] $ Spec.describe "HTTPure" do
  BodySpec.bodySpec
  HeadersSpec.headersSpec
  HTTPureEffectsSpec.httpureEffectsSpec
  LookupSpec.lookupSpec
  MethodSpec.methodSpec
  PathSpec.pathSpec
  QuerySpec.querySpec
  RequestSpec.requestSpec
  ResponseSpec.responseSpec
  ServerSpec.serverSpec
  StatusSpec.statusSpec
  IntegrationSpec.integrationSpec
