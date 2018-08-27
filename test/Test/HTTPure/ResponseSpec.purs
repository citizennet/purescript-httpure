module Test.HTTPure.ResponseSpec where

import Prelude

import Data.Either as Either
import Effect.Aff as Aff
import Effect.Class as EffectClass
import Node.Encoding as Encoding
import Node.HTTP as HTTP
import Node.Stream as Stream
import Test.Spec as Spec

import HTTPure.Body as Body
import HTTPure.Headers as Headers
import HTTPure.Response as Response

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
      , writeBody: \response -> Aff.makeAff \done -> do
          stream <- pure $ HTTP.responseAsStream response
          _ <- Stream.writeString stream Encoding.UTF8 "test" $ pure unit
          _ <- Stream.end stream $ pure unit
          done $ Either.Right unit
          pure Aff.nonCanceler
      }

responseFunctionSpec :: TestHelpers.Test
responseFunctionSpec = Spec.describe "response" do
  Spec.it "has the right status" do
    resp <- Response.response 123 "test"
    resp.status ?= 123
  Spec.it "has only default headers" do
    resp <- Response.response 123 "test"
    defaultHeaders <- EffectClass.liftEffect $ Body.additionalHeaders "test"
    resp.headers ?= defaultHeaders
  Spec.it "has the right writeBody function" do
    body <- do
      resp <- Response.response 123 "test"
      httpResponse <- EffectClass.liftEffect $ TestHelpers.mockResponse
      resp.writeBody httpResponse
      pure $ TestHelpers.getResponseBody httpResponse
    body ?= "test"

response'Spec :: TestHelpers.Test
response'Spec = Spec.describe "response'" do
  Spec.it "has the right status" do
    resp <- mockResponse
    resp.status ?= 123
  Spec.it "has the right headers" do
    resp <- mockResponse
    defaultHeaders <- EffectClass.liftEffect $ Body.additionalHeaders "test"
    resp.headers ?= defaultHeaders <> mockHeaders
  Spec.it "has the right writeBody function" do
    body <- do
      resp <- mockResponse
      httpResponse <- EffectClass.liftEffect $ TestHelpers.mockResponse
      resp.writeBody httpResponse
      pure $ TestHelpers.getResponseBody httpResponse
    body ?= "test"
  where
    mockHeaders = Headers.header "Test" "test"
    mockResponse = Response.response' 123 mockHeaders "test"

emptyResponseSpec :: TestHelpers.Test
emptyResponseSpec = Spec.describe "emptyResponse" do
  Spec.it "has the right status" do
    resp <- Response.emptyResponse 123
    resp.status ?= 123
  Spec.it "has only default headers" do
    resp <- Response.emptyResponse 123
    defaultHeaders <- EffectClass.liftEffect $ Body.additionalHeaders ""
    resp.headers ?= defaultHeaders
  Spec.it "has the right writeBody function" do
    body <- do
      resp <- Response.emptyResponse 123
      httpResponse <- EffectClass.liftEffect $ TestHelpers.mockResponse
      resp.writeBody httpResponse
      pure $ TestHelpers.getResponseBody httpResponse
    body ?= ""

emptyResponse'Spec :: TestHelpers.Test
emptyResponse'Spec = Spec.describe "emptyResponse'" do
  Spec.it "has the right status" do
    resp <- mockResponse
    resp.status ?= 123
  Spec.it "has the right headers" do
    resp <- mockResponse
    defaultHeaders <- EffectClass.liftEffect $ Body.additionalHeaders ""
    resp.headers ?= mockHeaders <> defaultHeaders
  Spec.it "has the right writeBody function" do
    body <- do
      resp <- mockResponse
      httpResponse <- EffectClass.liftEffect $ TestHelpers.mockResponse
      resp.writeBody httpResponse
      pure $ TestHelpers.getResponseBody httpResponse
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
