module Test.HTTPure.ResponseSpec where

import Prelude
import Data.Either (Either(Right))
import Effect.Aff (makeAff, nonCanceler)
import Effect.Class (liftEffect)
import Node.Encoding (Encoding(UTF8))
import Node.HTTP (responseAsStream)
import Node.Stream (writeString, end)
import Test.Spec (describe, it)
import HTTPure.Body (defaultHeaders)
import HTTPure.Headers (header)
import HTTPure.Response (send, response, response', emptyResponse, emptyResponse')
import Test.HTTPure.TestHelpers
  ( Test
  , (?=)
  , mockResponse
  , getResponseHeader
  , getResponseStatus
  , getResponseBody
  )

sendSpec :: Test
sendSpec =
  describe "send" do
    let
      mockResponse' =
        { status: 123
        , headers: header "Test" "test"
        , writeBody:
            \response -> makeAff \done -> do
              stream <- pure $ responseAsStream response
              void $ writeString stream UTF8 "test" $ const (end stream $ const (done $ Right unit))
              pure nonCanceler
        }
    it "writes the headers" do
      header <- do
        httpResponse <- liftEffect mockResponse
        send httpResponse mockResponse'
        pure $ getResponseHeader "Test" httpResponse
      header ?= "test"
    it "writes the status" do
      status <- do
        httpResponse <- liftEffect mockResponse
        send httpResponse mockResponse'
        pure $ getResponseStatus httpResponse
      status ?= 123
    it "writes the body" do
      body <- do
        httpResponse <- liftEffect mockResponse
        send httpResponse mockResponse'
        pure $ getResponseBody httpResponse
      body ?= "test"

responseFunctionSpec :: Test
responseFunctionSpec =
  describe "response" do
    it "has the right status" do
      resp <- response 123 "test"
      resp.status ?= 123
    it "has only default headers" do
      resp <- response 123 "test"
      defaultHeaders' <- liftEffect $ defaultHeaders "test"
      resp.headers ?= defaultHeaders'
    it "has the right writeBody function" do
      body <- do
        resp <- response 123 "test"
        httpResponse <- liftEffect $ mockResponse
        resp.writeBody httpResponse
        pure $ getResponseBody httpResponse
      body ?= "test"

response'Spec :: Test
response'Spec =
  describe "response'" do
    let
      mockHeaders = header "Test" "test"
      mockResponse' = response' 123 mockHeaders "test"
    it "has the right status" do
      resp <- mockResponse'
      resp.status ?= 123
    it "has the right headers" do
      resp <- mockResponse'
      defaultHeaders' <- liftEffect $ defaultHeaders "test"
      resp.headers ?= defaultHeaders' <> mockHeaders
    it "has the right writeBody function" do
      body <- do
        resp <- mockResponse'
        httpResponse <- liftEffect mockResponse
        resp.writeBody httpResponse
        pure $ getResponseBody httpResponse
      body ?= "test"

emptyResponseSpec :: Test
emptyResponseSpec =
  describe "emptyResponse" do
    it "has the right status" do
      resp <- emptyResponse 123
      resp.status ?= 123
    it "has only default headers" do
      resp <- emptyResponse 123
      defaultHeaders' <- liftEffect $ defaultHeaders ""
      resp.headers ?= defaultHeaders'
    it "has the right writeBody function" do
      body <- do
        resp <- emptyResponse 123
        httpResponse <- liftEffect $ mockResponse
        resp.writeBody httpResponse
        pure $ getResponseBody httpResponse
      body ?= ""

emptyResponse'Spec :: Test
emptyResponse'Spec =
  describe "emptyResponse'" do
    let
      mockHeaders = header "Test" "test"
      mockResponse' = emptyResponse' 123 mockHeaders
    it "has the right status" do
      resp <- mockResponse'
      resp.status ?= 123
    it "has the right headers" do
      resp <- mockResponse'
      defaultHeaders' <- liftEffect $ defaultHeaders ""
      resp.headers ?= mockHeaders <> defaultHeaders'
    it "has the right writeBody function" do
      body <- do
        resp <- mockResponse'
        httpResponse <- liftEffect mockResponse
        resp.writeBody httpResponse
        pure $ getResponseBody httpResponse
      body ?= ""

responseSpec :: Test
responseSpec =
  describe "Response" do
    sendSpec
    responseFunctionSpec
    response'Spec
    emptyResponseSpec
    emptyResponse'Spec
