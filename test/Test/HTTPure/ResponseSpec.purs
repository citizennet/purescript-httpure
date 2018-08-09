module Test.HTTPure.ResponseSpec where

import Prelude

import Effect.Aff as Aff
import Effect.Class as EffectClass
import Node.Buffer as Buffer
import Node.Encoding as Encoding
import Partial.Unsafe as Unsafe
import Test.Spec as Spec

import HTTPure.Body as Body
import HTTPure.Headers as Headers
import HTTPure.Response as Response

import Test.HTTPure.TestHelpers as TestHelpers
import Test.HTTPure.TestHelpers ((?=))

-- | Assert that a response body equals the given string
bodyShouldEqual :: Body.Body -> String -> Aff.Aff Unit
bodyShouldEqual body str =
  if Body.isString body
  then Unsafe.unsafePartial Body.fromString body ?= str
  else do
    bodyAsStr <-
      EffectClass.liftEffect $ Buffer.toString Encoding.UTF8 $
        Unsafe.unsafePartial Body.fromBinary body
    bodyAsStr ?= str

sendSpec :: TestHelpers.Test
sendSpec = Spec.describe "send" do
  Spec.it "writes the headers" do
    header <- EffectClass.liftEffect do
      httpResponse <- TestHelpers.mockResponse
      Response.send httpResponse mockResponse
      pure $ TestHelpers.getResponseHeader "Test" httpResponse
    header ?= "test"
  Spec.it "sets the Content-Length header" do
    header <- EffectClass.liftEffect do
      httpResponse <- TestHelpers.mockResponse
      Response.send httpResponse mockResponse
      pure $ TestHelpers.getResponseHeader "Content-Length" httpResponse
    header ?= "4"
  Spec.it "writes the status" do
    status <- EffectClass.liftEffect do
      httpResponse <- TestHelpers.mockResponse
      Response.send httpResponse mockResponse
      pure $ TestHelpers.getResponseStatus httpResponse
    status ?= 123
  Spec.it "writes the body" do
    body <- EffectClass.liftEffect do
      httpResponse <- TestHelpers.mockResponse
      Response.send httpResponse mockResponse
      pure $ TestHelpers.getResponseBody httpResponse
    body ?= "test"
  where
    mockHeaders = Headers.header "Test" "test"
    mockResponse =
      { status: 123
      , headers: mockHeaders
      , body: Body.string "test"
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
    Body.isString resp.body ?= true
    bodyShouldEqual resp.body "test"

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
    Body.isString resp.body ?= true
    bodyShouldEqual resp.body "test"
  where
    mockHeaders = Headers.header "Test" "test"
    mockResponse = Response.response' 123 mockHeaders "test"

binaryResponseSpec :: TestHelpers.Test
binaryResponseSpec = Spec.describe "binaryResponse" do
  Spec.it "has the right status" do
    body <- EffectClass.liftEffect $ Buffer.fromString "test" Encoding.UTF8
    resp <- Response.binaryResponse 123 body
    resp.status ?= 123
  Spec.it "has empty headers" do
    body <- EffectClass.liftEffect $ Buffer.fromString "test" Encoding.UTF8
    resp <- Response.binaryResponse 123 body
    resp.headers ?= Headers.empty
  Spec.it "has the right body" do
    body <- EffectClass.liftEffect $ Buffer.fromString "test" Encoding.UTF8
    resp <- Response.binaryResponse 123 body
    Body.isBinary resp.body ?= true
    bodyShouldEqual resp.body "test"

binaryResponse'Spec :: TestHelpers.Test
binaryResponse'Spec = Spec.describe "binaryResponse'" do
  Spec.it "has the right status" do
    body <- EffectClass.liftEffect $ Buffer.fromString "test" Encoding.UTF8
    resp <- mockResponse body
    resp.status ?= 123
  Spec.it "has the right headers" do
    body <- EffectClass.liftEffect $ Buffer.fromString "test" Encoding.UTF8
    resp <- mockResponse body
    resp.headers ?= mockHeaders
  Spec.it "has the right body" do
    body <- EffectClass.liftEffect $ Buffer.fromString "test" Encoding.UTF8
    resp <- mockResponse body
    Body.isBinary resp.body ?= true
    bodyShouldEqual resp.body "test"
  where
    mockHeaders = Headers.header "Test" "test"
    mockResponse = Response.binaryResponse' 123 mockHeaders

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
    Body.isString resp.body ?= true
    bodyShouldEqual resp.body ""

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
    Body.isString resp.body ?= true
    bodyShouldEqual resp.body ""
  where
    mockHeaders = Headers.header "Test" "test"
    mockResponse = Response.emptyResponse' 123 mockHeaders

responseSpec :: TestHelpers.Test
responseSpec = Spec.describe "Response" do
  sendSpec
  responseFunctionSpec
  response'Spec
  binaryResponseSpec
  binaryResponse'Spec
  emptyResponseSpec
  emptyResponse'Spec
