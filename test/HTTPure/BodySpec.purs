module HTTPure.BodySpec where

import Prelude

import Control.Monad.Eff.Class as EffClass
import Test.Spec as Spec

import HTTPure.Body as Body

import HTTPure.SpecHelpers as SpecHelpers
import HTTPure.SpecHelpers ((?=))

readSpec :: SpecHelpers.Test
readSpec = Spec.describe "read" do
  Spec.it "is the body of the Request" do
    request <- SpecHelpers.mockRequest "GET" "" "test" []
    body <- Body.read request
    body ?= "test"

writeSpec :: SpecHelpers.Test
writeSpec = Spec.describe "write" do
  Spec.it "writes the string to the Response body" do
    body <- EffClass.liftEff do
      resp <- SpecHelpers.mockResponse
      Body.write resp "test"
      pure $ SpecHelpers.getResponseBody resp
    body ?= "test"

bodySpec :: SpecHelpers.Test
bodySpec = Spec.describe "Body" do
  readSpec
  writeSpec
