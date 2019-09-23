module Test.Main where

import Prelude

import Effect.Aff as Aff
import Test.Spec as Spec
import Test.Spec.Reporter as Reporter
import Test.Spec.Runner as Runner

import Test.HTTPure.BodySpec as BodySpec
import Test.HTTPure.HeadersSpec as HeadersSpec
import Test.HTTPure.LookupSpec as LookupSpec
import Test.HTTPure.MethodSpec as MethodSpec
import Test.HTTPure.PathSpec as PathSpec
import Test.HTTPure.QuerySpec as QuerySpec
import Test.HTTPure.RequestSpec as RequestSpec
import Test.HTTPure.ResponseSpec as ResponseSpec
import Test.HTTPure.ServerSpec as ServerSpec
import Test.HTTPure.StatusSpec as StatusSpec
import Test.HTTPure.VersionSpec as VersionSpec
import Test.HTTPure.IntegrationSpec as IntegrationSpec

import Test.HTTPure.TestHelpers as TestHelpers

main :: TestHelpers.TestSuite
main = Aff.launchAff_ $ Runner.runSpec [ Reporter.specReporter ] $ Spec.describe "HTTPure" do
  BodySpec.bodySpec
  HeadersSpec.headersSpec
  LookupSpec.lookupSpec
  MethodSpec.methodSpec
  PathSpec.pathSpec
  QuerySpec.querySpec
  RequestSpec.requestSpec
  ResponseSpec.responseSpec
  ServerSpec.serverSpec
  StatusSpec.statusSpec
  VersionSpec.versionSpec
  IntegrationSpec.integrationSpec
