module HTTPure.BodySpec where

import Prelude (bind, discard, pure, ($))

import Control.Monad.Eff.Class as EffClass
import Test.Spec as Spec
import Test.Spec.Assertions as Assertions

import HTTPure.Body as Body

import HTTPure.SpecHelpers as SpecHelpers

writeSpec :: SpecHelpers.Test
writeSpec = Spec.describe "write" do
  Spec.it "writes the string to the Response body" do
    body <- EffClass.liftEff do
      resp <- SpecHelpers.mockResponse
      Body.write resp "test"
      pure $ SpecHelpers.getResponseBody resp
    body `Assertions.shouldEqual` "test"

bodySpec :: SpecHelpers.Test
bodySpec = Spec.describe "Body" do
  writeSpec
