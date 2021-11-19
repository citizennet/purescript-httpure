module Test.Main where

import Prelude
import Effect.Aff (launchAff_)
import Test.Spec (describe)
import Test.Spec.Reporter (specReporter)
import Test.Spec.Runner (runSpec)
import Test.HTTPure.BodySpec (bodySpec)
import Test.HTTPure.HeadersSpec (headersSpec)
import Test.HTTPure.LookupSpec (lookupSpec)
import Test.HTTPure.MethodSpec (methodSpec)
import Test.HTTPure.PathSpec (pathSpec)
import Test.HTTPure.QuerySpec (querySpec)
import Test.HTTPure.RequestSpec (requestSpec)
import Test.HTTPure.ResponseSpec (responseSpec)
import Test.HTTPure.ServerSpec (serverSpec)
import Test.HTTPure.StatusSpec (statusSpec)
import Test.HTTPure.UtilsSpec (utilsSpec)
import Test.HTTPure.VersionSpec (versionSpec)
import Test.HTTPure.IntegrationSpec (integrationSpec)
import Test.HTTPure.TestHelpers (TestSuite)

main :: TestSuite
main = launchAff_ $ runSpec [ specReporter ] $ describe "HTTPure" do
  bodySpec
  headersSpec
  lookupSpec
  methodSpec
  pathSpec
  querySpec
  requestSpec
  responseSpec
  serverSpec
  statusSpec
  utilsSpec
  versionSpec
  integrationSpec
