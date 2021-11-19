module Test.HTTPure.BodySpec where

import Prelude
import Data.Maybe (Maybe(Nothing), fromMaybe)
import Effect.Class (liftEffect)
import Node.Buffer (toString) as Buffer
import Node.Buffer (Buffer, fromString)
import Node.Encoding (Encoding(UTF8))
import Node.Stream (readString)
import Test.Spec (describe, it)
import HTTPure.Body (read, toString, toBuffer, defaultHeaders, write)
import HTTPure.Headers (header)
import Test.HTTPure.TestHelpers (Test, (?=), mockRequest, mockResponse, getResponseBody, stringToStream)

readSpec :: Test
readSpec =
  describe "read" do
    it "is the body of the Request" do
      body <- read <$> mockRequest "" "GET" "" "test" []
      string <- liftEffect $ fromMaybe "" <$> readString body Nothing UTF8
      string ?= "test"

toStringSpec :: Test
toStringSpec =
  describe "toString" do
    it "slurps Streams into Strings" do
      string <- toString $ stringToStream "foobar"
      string ?= "foobar"

toBufferSpec :: Test
toBufferSpec =
  describe "toBuffer" do
    it "slurps Streams into Buffers" do
      buf <- toBuffer $ stringToStream "foobar"
      string <- liftEffect $ Buffer.toString UTF8 buf
      string ?= "foobar"

defaultHeadersSpec :: Test
defaultHeadersSpec =
  describe "defaultHeaders" do
    describe "String" do
      describe "with an ASCII string" do
        it "has the correct Content-Length header" do
          headers <- liftEffect $ defaultHeaders "ascii"
          headers ?= header "Content-Length" "5"
      describe "with a UTF-8 string" do
        it "has the correct Content-Length header" do
          headers <- liftEffect $ defaultHeaders "\x2603"
          headers ?= header "Content-Length" "3"
    describe "Buffer" do
      it "has the correct Content-Length header" do
        buf :: Buffer <- liftEffect $ fromString "foobar" UTF8
        headers <- liftEffect $ defaultHeaders buf
        headers ?= header "Content-Length" "6"
    describe "Readable" do
      it "specifies the Transfer-Encoding header" do
        headers <- liftEffect $ defaultHeaders $ stringToStream "test"
        headers ?= header "Transfer-Encoding" "chunked"

writeSpec :: Test
writeSpec =
  describe "write" do
    describe "String" do
      it "writes the String to the Response body" do
        body <- do
          resp <- liftEffect mockResponse
          write "test" resp
          pure $ getResponseBody resp
        body ?= "test"
    describe "Buffer" do
      it "writes the Buffer to the Response body" do
        body <- do
          resp <- liftEffect mockResponse
          buf :: Buffer <- liftEffect $ fromString "test" UTF8
          write buf resp
          pure $ getResponseBody resp
        body ?= "test"
    describe "Readable" do
      it "pipes the input stream to the Response body" do
        body <- do
          resp <- liftEffect mockResponse
          write (stringToStream "test") resp
          pure $ getResponseBody resp
        body ?= "test"

bodySpec :: Test
bodySpec =
  describe "Body" do
    defaultHeadersSpec
    readSpec
    toStringSpec
    toBufferSpec
    writeSpec
