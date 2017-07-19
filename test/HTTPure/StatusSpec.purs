module HTTPure.StatusSpec where

import Prelude

import Control.Monad.Eff.Class as EffClass
import Test.Spec as Spec

import HTTPure.Status as Status

import HTTPure.SpecHelpers as SpecHelpers
import HTTPure.SpecHelpers ((?=))

writeSpec :: SpecHelpers.Test
writeSpec = Spec.describe "write" do
  Spec.it "writes the given status code" do
    status <- EffClass.liftEff do
      mock <- SpecHelpers.mockResponse
      Status.write mock 123
      pure $ SpecHelpers.getResponseStatus mock
    status ?= 123

statusSpec :: SpecHelpers.Test
statusSpec = Spec.describe "Status" do
  writeSpec
