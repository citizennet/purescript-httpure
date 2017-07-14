module HTTPure.ResponseSpec where

import Prelude (bind, discard, ($))

import Control.Monad.Eff.Class as EffClass
import Data.StrMap as StrMap
import Node.Encoding as Encoding
import Node.StreamBuffer as StreamBuffer
import Test.Spec as Spec
import Test.Spec.Assertions as Assertions

import HTTPure.Response as Response

import HTTPure.SpecHelpers as SpecHelpers

sendSpec :: SpecHelpers.Test
sendSpec = Spec.describe "send" do
  Spec.describe "with an OK" do
    Spec.pending "writes the headers"
    Spec.it "writes the body" do
      body <- EffClass.liftEff do
        buf <- StreamBuffer.writable
        let resp = SpecHelpers.mockResponse buf
        Response.send resp $ Response.OK StrMap.empty "test"
        StreamBuffer.contents Encoding.UTF8 buf
      body `Assertions.shouldEqual` "test"

responseSpec :: SpecHelpers.Test
responseSpec = Spec.describe "Response" do
  sendSpec
