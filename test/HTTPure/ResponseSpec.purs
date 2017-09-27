module HTTPure.ResponseSpec where

import Prelude

import Control.Monad.Eff.Class as EffClass
import Data.Tuple as Tuple

import Test.Spec as Spec

import HTTPure.Headers as Headers
import HTTPure.Response as Response

import HTTPure.SpecHelpers as SpecHelpers
import HTTPure.SpecHelpers ((?=))

sendSpec :: SpecHelpers.Test
sendSpec = Spec.describe "send" do
  Spec.it "writes the headers" do
    header <- EffClass.liftEff do
      httpResponse <- SpecHelpers.mockResponse
      Response.send httpResponse mockResponse
      pure $ SpecHelpers.getResponseHeader "Test" httpResponse
    header ?= "test"
  Spec.it "writes the status" do
    status <- EffClass.liftEff do
      httpResponse <- SpecHelpers.mockResponse
      Response.send httpResponse mockResponse
      pure $ SpecHelpers.getResponseStatus httpResponse
    status ?= 123
  Spec.it "writes the body" do
    body <- EffClass.liftEff do
      httpResponse <- SpecHelpers.mockResponse
      Response.send httpResponse mockResponse
      pure $ SpecHelpers.getResponseBody httpResponse
    body ?= "test"
  where
    mockHeaders = Headers.headers [ Tuple.Tuple "Test" "test" ]
    mockResponse = { status: 123, headers: mockHeaders, body: "test" }

responseFunctionSpec :: SpecHelpers.Test
responseFunctionSpec = Spec.describe "response" do
  Spec.it "has the right status" do
    resp <- mockResponse
    resp.status ?= 123
  Spec.it "has the right headers" do
    resp <- mockResponse
    resp.headers ?= mockHeaders
  Spec.it "has the right body" do
    resp <- mockResponse
    resp.body ?= "test"
  where
    mockHeaders = Headers.headers [ Tuple.Tuple "Test" "test" ]
    mockResponse = Response.response 123 mockHeaders "test"

response'Spec :: SpecHelpers.Test
response'Spec = Spec.describe "response'" do
  Spec.it "has the right status" do
    resp <- mockResponse
    resp.status ?= 123
  Spec.it "has the right headers" do
    resp <- mockResponse
    resp.headers ?= mockHeaders
  Spec.it "has an empty body" do
    resp <- mockResponse
    resp.body ?= ""
  where
    mockHeaders = Headers.headers [ Tuple.Tuple "Test" "test" ]
    mockResponse = Response.response' 123 mockHeaders

responseSpec :: SpecHelpers.Test
responseSpec = Spec.describe "Response" do
  sendSpec
  responseFunctionSpec
  response'Spec
