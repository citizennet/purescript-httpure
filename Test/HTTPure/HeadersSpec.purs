module HTTPure.HeadersSpec where

import Prelude (bind, discard, pure, ($))

import Control.Monad.Eff.Class as EffClass
import Data.StrMap as StrMap
import Test.Spec as Spec
import Test.Spec.Assertions as Assertions

import HTTPure.Headers as Headers

import HTTPure.SpecHelpers as SpecHelpers

writeSpec :: SpecHelpers.Test
writeSpec = Spec.describe "write" do
  Spec.it "writes the headers to the response" do
    header <- EffClass.liftEff do
      mock <- SpecHelpers.mockResponse
      Headers.write mock $ StrMap.singleton "X-Test" "test"
      pure $ SpecHelpers.getResponseHeader mock "X-Test"
    header `Assertions.shouldEqual` "test"

headersSpec :: SpecHelpers.Test
headersSpec = Spec.describe "Headers" do
  writeSpec
