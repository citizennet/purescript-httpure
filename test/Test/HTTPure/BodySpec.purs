module Test.HTTPure.BodySpec where

import Prelude

import Effect.Class as EffectClass
import Node.Buffer as Buffer
import Node.Encoding as Encoding
import Test.Spec as Spec

import HTTPure.Body as Body
import HTTPure.Headers as Headers

import Test.HTTPure.TestHelpers as TestHelpers
import Test.HTTPure.TestHelpers ((?=))

readSpec :: TestHelpers.Test
readSpec = Spec.describe "read" do
  Spec.it "is the body of the Request" do
    request <- TestHelpers.mockRequest "" "GET" "" "test" []
    body <- Body.read request
    body ?= "test"

defaultHeadersSpec :: TestHelpers.Test
defaultHeadersSpec = Spec.describe "defaultHeaders" do
  Spec.describe "String" do
    Spec.describe "with an ASCII string" do
      Spec.it "has the correct Content-Length header" do
        headers <- EffectClass.liftEffect $ Body.defaultHeaders "ascii"
        headers ?= Headers.header "Content-Length" "5"
    Spec.describe "with a UTF-8 string" do
      Spec.it "has the correct Content-Length header" do
        headers <- EffectClass.liftEffect $ Body.defaultHeaders "\x2603"
        headers ?= Headers.header "Content-Length" "3"
  Spec.describe "Buffer" do
    Spec.it "has the correct Content-Length header" do
      buf :: Buffer.Buffer <- EffectClass.liftEffect $ Buffer.fromString "foobar" Encoding.UTF8
      headers <- EffectClass.liftEffect $ Body.defaultHeaders buf
      headers ?= Headers.header "Content-Length" "6"
  Spec.describe "Readable" do
    Spec.it "specifies the Transfer-Encoding header" do
      let body = TestHelpers.stringToStream "test"
      headers <- EffectClass.liftEffect $ Body.defaultHeaders body
      headers ?= Headers.header "Transfer-Encoding" "chunked"

writeSpec :: TestHelpers.Test
writeSpec = Spec.describe "write" do
  Spec.describe "String" do
    Spec.it "writes the String to the Response body" do
      body <- do
        resp <- EffectClass.liftEffect TestHelpers.mockResponse
        Body.write "test" resp
        pure $ TestHelpers.getResponseBody resp
      body ?= "test"
  Spec.describe "Buffer" do
    Spec.it "writes the Buffer to the Response body" do
      body <- do
        resp <- EffectClass.liftEffect TestHelpers.mockResponse
        buf :: Buffer.Buffer <- EffectClass.liftEffect $ Buffer.fromString "test" Encoding.UTF8
        Body.write buf resp
        pure $ TestHelpers.getResponseBody resp
      body ?= "test"
  Spec.describe "Readable" do
    Spec.it "pipes the input stream to the Response body" do
      body <- do
        resp <- EffectClass.liftEffect TestHelpers.mockResponse
        Body.write (TestHelpers.stringToStream "test") resp
        pure $ TestHelpers.getResponseBody resp
      body ?= "test"

bodySpec :: TestHelpers.Test
bodySpec = Spec.describe "Body" do
  defaultHeadersSpec
  readSpec
  writeSpec
