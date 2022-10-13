module Test.HTTPure.BodySpec where

import Prelude

import Data.Maybe (Maybe(Nothing), fromMaybe)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Ref (new) as Ref
import HTTPure.Body (RequestBody, defaultHeaders, read, toBuffer, toStream, toString, write)
import HTTPure.ResponseHeaders (header)
import Node.Buffer (Buffer, fromString)
import Node.Buffer (toString) as Buffer
import Node.Encoding (Encoding(UTF8))
import Node.Stream (readString)
import Test.HTTPure.TestHelpers (Test, getResponseBody, mockRequest, mockResponse, stringToStream, (?=))
import Test.Spec (describe, it)

mockRequestBody :: String -> Aff RequestBody
mockRequestBody body =
  liftEffect do
    buffer <- Ref.new Nothing
    string <- Ref.new Nothing
    pure
      { buffer
      , stream: stringToStream body
      , string
      }

readSpec :: Test
readSpec =
  describe "read" do
    it "is the body of the Request" do
      body <- (liftEffect <<< read) =<< mockRequest "" "GET" "" "test" []
      string <- liftEffect $ fromMaybe "" <$> readString (toStream body) Nothing UTF8
      string ?= "test"

toStringSpec :: Test
toStringSpec =
  describe "toString" do
    it "turns RequestBody into a String" do
      requestBody <- mockRequestBody "foobar"
      string <- toString requestBody
      string ?= "foobar"
    it "is idempotent" do
      requestBody <- mockRequestBody "foobar"
      string1 <- toString requestBody
      string2 <- toString requestBody
      string1 ?= string2

toBufferSpec :: Test
toBufferSpec =
  describe "toBuffer" do
    it "turns RequestBody into a Buffer" do
      requestBody <- mockRequestBody "foobar"
      buf <- toBuffer requestBody
      string <- liftEffect $ Buffer.toString UTF8 buf
      string ?= "foobar"
    it "is idempotent" do
      requestBody <- mockRequestBody "foobar"
      buffer1 <- toBuffer requestBody
      buffer2 <- toBuffer requestBody
      string1 <- bufferToString buffer1
      string2 <- bufferToString buffer2
      string1 ?= string2
  where
  bufferToString = liftEffect <<< Buffer.toString UTF8

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
