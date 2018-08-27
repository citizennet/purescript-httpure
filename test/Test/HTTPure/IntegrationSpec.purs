module Test.HTTPure.IntegrationSpec where

import Prelude

import Effect.Class as EffectClass
import Foreign.Object as Object
import Node.Buffer as Buffer
import Node.FS.Aff as FS
import Test.Spec as Spec

import Test.HTTPure.TestHelpers as TestHelpers
import Test.HTTPure.TestHelpers ((?=))

import Examples.AsyncResponse.Main as AsyncResponse
import Examples.Binary.Main as Binary
import Examples.Chunked.Main as Chunked
import Examples.Headers.Main as Headers
import Examples.HelloWorld.Main as HelloWorld
import Examples.Middleware.Main as Middleware
import Examples.MultiRoute.Main as MultiRoute
import Examples.PathSegments.Main as PathSegments
import Examples.Post.Main as Post
import Examples.QueryParameters.Main as QueryParameters
import Examples.SSL.Main as SSL

asyncResponseSpec :: TestHelpers.Test
asyncResponseSpec = Spec.it "runs the async response example" do
  EffectClass.liftEffect AsyncResponse.main
  response <- TestHelpers.get port Object.empty "/"
  response ?= "hello world!"
  where port = AsyncResponse.port

binarySpec :: TestHelpers.Test
binarySpec = Spec.it "runs the binary example" do
  binaryBuf <- FS.readFile Binary.filePath
  expected <- EffectClass.liftEffect $ Buffer.toArray binaryBuf
  EffectClass.liftEffect Binary.main
  responseBuf <- TestHelpers.getBinary port Object.empty "/"
  response <- EffectClass.liftEffect $ Buffer.toArray responseBuf
  response ?= expected
  where port = Binary.port

chunkedSpec :: TestHelpers.Test
chunkedSpec = Spec.it "runs the chunked example" do
  EffectClass.liftEffect Chunked.main
  response <- TestHelpers.get port Object.empty "/"
  -- TODO this isn't a great way to validate this, we need a way of inspecting
  -- each individual chunk instead of just looking at the entire response
  response ?= "hello world!"
  where port = Chunked.port

headersSpec :: TestHelpers.Test
headersSpec = Spec.it "runs the headers example" do
  EffectClass.liftEffect Headers.main
  header <- TestHelpers.getHeader port Object.empty "/" "X-Example"
  header ?= "hello world!"
  response <- TestHelpers.get port (Object.singleton "X-Input" "test") "/"
  response ?= "test"
  where port = Headers.port

helloWorldSpec :: TestHelpers.Test
helloWorldSpec = Spec.it "runs the hello world example" do
  EffectClass.liftEffect HelloWorld.main
  response <- TestHelpers.get port Object.empty "/"
  response ?= "hello world!"
  where port = HelloWorld.port

middlewareSpec :: TestHelpers.Test
middlewareSpec = Spec.it "runs the middleware example" do
  EffectClass.liftEffect Middleware.main
  header <- TestHelpers.getHeader port Object.empty "/" "X-Middleware"
  header ?= "router"
  body <- TestHelpers.get port Object.empty "/"
  body ?= "hello"
  header' <- TestHelpers.getHeader port Object.empty "/middleware" "X-Middleware"
  header' ?= "middleware"
  body' <- TestHelpers.get port Object.empty "/middleware"
  body' ?= "Middleware!"
  where port = Middleware.port

multiRouteSpec :: TestHelpers.Test
multiRouteSpec = Spec.it "runs the multi route example" do
  EffectClass.liftEffect MultiRoute.main
  hello <- TestHelpers.get port Object.empty "/hello"
  hello ?= "hello"
  goodbye <- TestHelpers.get port Object.empty "/goodbye"
  goodbye ?= "goodbye"
  where port = MultiRoute.port

pathSegmentsSpec :: TestHelpers.Test
pathSegmentsSpec = Spec.it "runs the path segments example" do
  EffectClass.liftEffect PathSegments.main
  foo <- TestHelpers.get port Object.empty "/segment/foo"
  foo ?= "foo"
  somebars <- TestHelpers.get port Object.empty "/some/bars"
  somebars ?= "[\"some\",\"bars\"]"
  where port = PathSegments.port

postSpec :: TestHelpers.Test
postSpec = Spec.it "runs the post example" do
  EffectClass.liftEffect Post.main
  response <- TestHelpers.post port Object.empty "/" "test"
  response ?= "test"
  where port = Post.port

queryParametersSpec :: TestHelpers.Test
queryParametersSpec = Spec.it "runs the query parameters example" do
  EffectClass.liftEffect QueryParameters.main
  foo <- TestHelpers.get port Object.empty "/?foo"
  foo ?= "foo"
  bar <- TestHelpers.get port Object.empty "/?bar=test"
  bar ?= "bar"
  notbar <- TestHelpers.get port Object.empty "/?bar=nottest"
  notbar ?= ""
  baz <- TestHelpers.get port Object.empty "/?baz=test"
  baz ?= "test"
  where port = QueryParameters.port

sslSpec :: TestHelpers.Test
sslSpec = Spec.it "runs the ssl example" do
  EffectClass.liftEffect SSL.main
  response <- TestHelpers.get' port Object.empty "/"
  response ?= "hello world!"
  where port = SSL.port

integrationSpec :: TestHelpers.Test
integrationSpec = Spec.describe "Integration" do
  asyncResponseSpec
  binarySpec
  chunkedSpec
  headersSpec
  helloWorldSpec
  middlewareSpec
  multiRouteSpec
  pathSegmentsSpec
  postSpec
  queryParametersSpec
  sslSpec
