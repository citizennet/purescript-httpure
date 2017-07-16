module HTTPure.BodySpec where

import Prelude (bind, discard)

import Control.Monad.Eff.Class as EffClass
import Node.Encoding as Encoding
import Node.StreamBuffer as StreamBuffer
import Test.Spec as Spec
import Test.Spec.Assertions as Assertions

import HTTPure.Body as Body

import HTTPure.SpecHelpers as SpecHelpers

writeSpec :: SpecHelpers.Test
writeSpec = Spec.describe "write" do
  Spec.it "writes the string to the Response body" do
    body <- EffClass.liftEff do
      buf <- StreamBuffer.writable
      let resp = SpecHelpers.mockResponse buf
      Body.write resp "test"
      StreamBuffer.contents Encoding.UTF8 buf
    body `Assertions.shouldEqual` "test"

bodySpec :: SpecHelpers.Test
bodySpec = Spec.describe "Body" do
  writeSpec
