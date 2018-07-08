module Test.HTTPure.BodySpec where

import Prelude

import Effect.Class as EffectClass
import Test.Spec as Spec

import HTTPure.Body as Body

import Test.HTTPure.TestHelpers as TestHelpers
import Test.HTTPure.TestHelpers ((?=))

readSpec :: TestHelpers.Test
readSpec = Spec.describe "read" do
  Spec.it "is the body of the Request" do
    request <- TestHelpers.mockRequest "GET" "" "test" []
    body <- Body.read request
    body ?= "test"

writeSpec :: TestHelpers.Test
writeSpec = Spec.describe "write" do
  Spec.it "writes the string to the Response body" do
    body <- EffectClass.liftEffect do
      resp <- TestHelpers.mockResponse
      Body.write resp "test"
      pure $ TestHelpers.getResponseBody resp
    body ?= "test"

bodySpec :: TestHelpers.Test
bodySpec = Spec.describe "Body" do
  readSpec
  writeSpec
