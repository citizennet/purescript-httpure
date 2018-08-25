module Test.HTTPure.ResponseSpec where

import Prelude

import Data.Maybe as Maybe
import Effect.Class as EffectClass
import Test.Spec as Spec

import HTTPure.Headers as Headers
import HTTPure.Response as Response
import HTTPure.Streamable as Streamable

import Test.HTTPure.TestHelpers as TestHelpers
import Test.HTTPure.TestHelpers ((?=))

sendSpec :: TestHelpers.Test
sendSpec = Spec.describe "send" do
  Spec.it "writes the headers" do
    header <- do
      httpResponse <- EffectClass.liftEffect $ TestHelpers.mockResponse
      Response.send httpResponse $ mockResponse unit
      pure $ TestHelpers.getResponseHeader "Test" httpResponse
    header ?= "test"
  Spec.it "sets the Content-Length header" do
    header <- do
      httpResponse <- EffectClass.liftEffect $ TestHelpers.mockResponse
      Response.send httpResponse $ mockResponse unit
      pure $ TestHelpers.getResponseHeader "Content-Length" httpResponse
    header ?= "4"
  Spec.it "writes the status" do
    status <- do
      httpResponse <- EffectClass.liftEffect $ TestHelpers.mockResponse
      Response.send httpResponse $ mockResponse unit
      pure $ TestHelpers.getResponseStatus httpResponse
    status ?= 123
  Spec.it "writes the body" do
    body <- do
      httpResponse <- EffectClass.liftEffect $ TestHelpers.mockResponse
      Response.send httpResponse $ mockResponse unit
      pure $ TestHelpers.getResponseBody httpResponse
    body ?= "test"
  where
    mockHeaders = Headers.header "Test" "test"
    mockResponse _ =
      { status: 123
      , headers: mockHeaders
      , body: Streamable.toStream "test"
      , size: Maybe.Just 4
      }

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
    body <- TestHelpers.streamToString resp.body
    body ?= "test"

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
    body <- TestHelpers.streamToString resp.body
    body ?= "test"
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
    body <- TestHelpers.streamToString resp.body
    body ?= ""

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
    body <- TestHelpers.streamToString resp.body
    body ?= ""
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
