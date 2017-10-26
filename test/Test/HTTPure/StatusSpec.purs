module Test.HTTPure.StatusSpec where

import Prelude

import Control.Monad.Eff.Class as EffClass
import Test.Spec as Spec

import HTTPure.Status as Status

import Test.HTTPure.TestHelpers as TestHelpers
import Test.HTTPure.TestHelpers ((?=))

writeSpec :: TestHelpers.Test
writeSpec = Spec.describe "write" do
  Spec.it "writes the given status code" do
    status <- EffClass.liftEff do
      mock <- TestHelpers.mockResponse
      Status.write mock 123
      pure $ TestHelpers.getResponseStatus mock
    status ?= 123

statusSpec :: TestHelpers.Test
statusSpec = Spec.describe "Status" do
  writeSpec
