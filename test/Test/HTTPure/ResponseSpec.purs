module Test.HTTPure.ResponseSpec where

import Prelude

import Control.Monad.Eff.Class as EffClass
import Test.Spec as Spec

import HTTPure.Headers as Headers
import HTTPure.Response as Response

import Test.HTTPure.TestHelpers as TestHelpers
import Test.HTTPure.TestHelpers ((?=))

sendSpec :: TestHelpers.Test
sendSpec = Spec.describe "send" do
  Spec.it "writes the headers" do
    header <- EffClass.liftEff do
      httpResponse <- TestHelpers.mockResponse
      Response.send httpResponse mockResponse
      pure $ TestHelpers.getResponseHeader "Test" httpResponse
    header ?= "test"
  Spec.it "writes the status" do
    status <- EffClass.liftEff do
      httpResponse <- TestHelpers.mockResponse
      Response.send httpResponse mockResponse
      pure $ TestHelpers.getResponseStatus httpResponse
    status ?= 123
  Spec.it "writes the body" do
    body <- EffClass.liftEff do
      httpResponse <- TestHelpers.mockResponse
      Response.send httpResponse mockResponse
      pure $ TestHelpers.getResponseBody httpResponse
    body ?= "test"
  where
    mockHeaders = Headers.header "Test" "test"
    mockResponse = { status: 123, headers: mockHeaders, body: "test" }

responseFunctionSpec :: TestHelpers.Test
responseFunctionSpec = Spec.describe "response" do
  Spec.it "has the right status" do
    resp <- Response.response 123 "test"
    resp.status ?= 123
  Spec.it "has empty headers" do
    resp <- Response.response 123 "test"
    resp.headers ?= Headers.empty
  Spec.it "has the right body" do
    resp <- Response.response 123 "test"
    resp.body ?= "test"

response'Spec :: TestHelpers.Test
response'Spec = Spec.describe "response'" do
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
    mockHeaders = Headers.header "Test" "test"
    mockResponse = Response.response' 123 mockHeaders "test"

emptyResponseSpec :: TestHelpers.Test
emptyResponseSpec = Spec.describe "emptyResponse" do
  Spec.it "has the right status" do
    resp <- Response.emptyResponse 123
    resp.status ?= 123
  Spec.it "has empty headers" do
    resp <- Response.emptyResponse 123
    resp.headers ?= Headers.empty
  Spec.it "has an empty body" do
    resp <- Response.emptyResponse 123
    resp.body ?= ""

emptyResponse'Spec :: TestHelpers.Test
emptyResponse'Spec = Spec.describe "emptyResponse'" do
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
    mockHeaders = Headers.header "Test" "test"
    mockResponse = Response.emptyResponse' 123 mockHeaders

responseSpec :: TestHelpers.Test
responseSpec = Spec.describe "Response" do
  sendSpec
  responseFunctionSpec
  response'Spec
  emptyResponseSpec
  emptyResponse'Spec
