module HTTPure.ResponseSpec where

import Prelude

import Control.Monad.Eff.Class as EffClass
import Data.StrMap as StrMap
import Test.Spec as Spec

import HTTPure.Response as Response

import HTTPure.SpecHelpers as SpecHelpers
import HTTPure.SpecHelpers ((?=))

sendSpec :: SpecHelpers.Test
sendSpec = Spec.describe "send" do
  Spec.it "writes the headers" do
    header <- EffClass.liftEff do
      resp <- SpecHelpers.mockResponse
      Response.send resp $ Response.OK (StrMap.singleton "X-Test" "test") ""
      pure $ SpecHelpers.getResponseHeader "X-Test" resp
    header ?= "test"
  Spec.it "writes the status" do
    status <- EffClass.liftEff do
      resp <- SpecHelpers.mockResponse
      Response.send resp $ Response.Response 465 StrMap.empty ""
      pure $ SpecHelpers.getResponseStatus resp
    status ?= 465
  Spec.it "writes the body" do
    body <- EffClass.liftEff do
      resp <- SpecHelpers.mockResponse
      Response.send resp $ Response.OK StrMap.empty "test"
      pure $ SpecHelpers.getResponseBody resp
    body ?= "test"

responseSpec :: SpecHelpers.Test
responseSpec = Spec.describe "Response" do
  sendSpec
