module HTTPure.ResponseSpec where

import Prelude (bind, discard, ($))

import Control.Monad.Eff.Class as EffClass
import Node.Encoding as Encoding
import Node.StreamBuffer as StreamBuffer
import Test.Spec as Spec
import Test.Spec.Assertions as Assertions

import HTTPure.SpecHelpers as SpecHelpers

import HTTPure.Response as Response

writeSpec :: SpecHelpers.Test
writeSpec = Spec.describe "write" $
  Spec.it "sets the response body" do
    body <- EffClass.liftEff do
      buf <- StreamBuffer.writable
      Response.write (SpecHelpers.mockResponse buf) "test"
      StreamBuffer.contents Encoding.UTF8 buf
    body `Assertions.shouldEqual` "test"

responseSpec :: SpecHelpers.Test
responseSpec = Spec.describe "Response" $
  writeSpec
