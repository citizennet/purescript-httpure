module HTTPure.StatusSpec where

import Prelude (bind, discard, pure)

import Control.Monad.Eff.Class as EffClass
import Node.StreamBuffer as StreamBuffer
import Test.Spec as Spec
import Test.Spec.Assertions as Assertions

import HTTPure.Status as Status

import HTTPure.SpecHelpers as SpecHelpers

writeSpec :: SpecHelpers.Test
writeSpec = Spec.describe "write" do
  Spec.it "writes the given status code" do
    resp <- EffClass.liftEff do
      buf <- StreamBuffer.writable
      let mock = SpecHelpers.mockResponse buf
      Status.write mock 123
      pure mock
    SpecHelpers.getResponseStatus resp `Assertions.shouldEqual` 123

statusSpec :: SpecHelpers.Test
statusSpec = Spec.describe "Status" do
  writeSpec
