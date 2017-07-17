module HTTPure.ResponseSpec where

import Prelude (bind, discard, pure, ($))

import Control.Monad.Eff.Class as EffClass
import Data.StrMap as StrMap
import Test.Spec as Spec
import Test.Spec.Assertions as Assertions

import HTTPure.Response as Response

import HTTPure.SpecHelpers as SpecHelpers

sendSpec :: SpecHelpers.Test
sendSpec = Spec.describe "send" do
  Spec.describe "with an OK" do
    Spec.it "writes the headers" do
      header <- EffClass.liftEff do
        resp <- SpecHelpers.mockResponse
        Response.send resp $ Response.OK (StrMap.singleton "X-Test" "test") ""
        pure $ SpecHelpers.getResponseHeader resp "X-Test"
      header `Assertions.shouldEqual` "test"
    Spec.it "writes the status" do
      status <- EffClass.liftEff do
        resp <- SpecHelpers.mockResponse
        Response.send resp $ Response.OK StrMap.empty ""
        pure $ SpecHelpers.getResponseStatus resp
      status `Assertions.shouldEqual` 200
    Spec.it "writes the body" do
      body <- EffClass.liftEff do
        resp <- SpecHelpers.mockResponse
        Response.send resp $ Response.OK StrMap.empty "test"
        pure $ SpecHelpers.getResponseBody resp
      body `Assertions.shouldEqual` "test"

responseSpec :: SpecHelpers.Test
responseSpec = Spec.describe "Response" do
  sendSpec
