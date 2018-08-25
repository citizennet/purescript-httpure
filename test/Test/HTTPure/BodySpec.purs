module Test.HTTPure.BodySpec where

import Prelude

import Effect.Class as EffectClass
import Node.Buffer as Buffer
import Node.Encoding as Encoding
import Test.Spec as Spec

import HTTPure.Body as Body

import Test.HTTPure.TestHelpers as TestHelpers
import Test.HTTPure.TestHelpers ((?=))

readSpec :: TestHelpers.Test
readSpec = Spec.describe "read" do
  Spec.it "is the body of the Request" do
    request <- TestHelpers.mockRequest "GET" "" "test" []
    body <- Body.read request
    body ?= "test"

sizeSpec :: TestHelpers.Test
sizeSpec = Spec.describe "size" do
  Spec.it "returns the correct size for ASCII string body" do
    size <- EffectClass.liftEffect $ Body.size $ Body.StringBody "ascii"
    size ?= 5

  Spec.it "returns the correct size for UTF-8 string body" do
    size <- EffectClass.liftEffect $ Body.size $ Body.StringBody "\x2603"  -- snowman
    size ?= 3

  Spec.it "returns the correct size for binary body" do
    size <- EffectClass.liftEffect do
      buf <- Buffer.fromString "foobar" Encoding.UTF8
      Body.size $ Body.BinaryBody buf
    size ?= 6

writeSpec :: TestHelpers.Test
writeSpec = Spec.describe "write" do
  Spec.it "writes the string to the Response body" do
    body <- EffectClass.liftEffect do
      resp <- TestHelpers.mockResponse
      Body.write resp $ Body.StringBody "test"
      pure $ TestHelpers.getResponseBody resp
    body ?= "test"

bodySpec :: TestHelpers.Test
bodySpec = Spec.describe "Body" do
  readSpec
  sizeSpec
  writeSpec
