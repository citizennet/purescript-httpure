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
import Examples.CustomStack.Main as CustomStack
import Examples.Headers.Main as Headers
import Examples.HelloWorld.Main as HelloWorld
import Examples.Middleware.Main as Middleware
import Examples.MultiRoute.Main as MultiRoute
import Examples.PathSegments.Main as PathSegments
import Examples.Post.Main as Post
import Examples.QueryParameters.Main as QueryParameters
import Examples.SSL.Main as SSL

asyncResponseSpec :: TestHelpers.Test
asyncResponseSpec =
  Spec.it "runs the async response example" do
    close <- EffectClass.liftEffect AsyncResponse.main
    response <- TestHelpers.get 8080 Object.empty "/"
    EffectClass.liftEffect $ close $ pure unit
    response ?= "hello world!"

binarySpec :: TestHelpers.Test
binarySpec =
  Spec.it "runs the binary example" do
    close <- EffectClass.liftEffect Binary.main
    responseBuf <- TestHelpers.getBinary 8080 Object.empty "/"
    EffectClass.liftEffect $ close $ pure unit
    binaryBuf <- FS.readFile Binary.filePath
    expected <- EffectClass.liftEffect $ Buffer.toArray binaryBuf
    response <- EffectClass.liftEffect $ Buffer.toArray responseBuf
    response ?= expected

chunkedSpec :: TestHelpers.Test
chunkedSpec =
  Spec.it "runs the chunked example" do
    close <- EffectClass.liftEffect Chunked.main
    response <- TestHelpers.get 8080 Object.empty "/"
    EffectClass.liftEffect $ close $ pure unit
    -- TODO this isn't a great way to validate this, we need a way of inspecting
    -- each individual chunk instead of just looking at the entire response
    response ?= "hello \nworld!\n"

customStackSpec :: TestHelpers.Test
customStackSpec =
  Spec.it "runs the custom stack example" do
    close <- EffectClass.liftEffect CustomStack.main
    response <- TestHelpers.get 8080 Object.empty "/"
    EffectClass.liftEffect $ close $ pure unit
    response ?= "hello, joe"

headersSpec :: TestHelpers.Test
headersSpec =
  Spec.it "runs the headers example" do
    close <- EffectClass.liftEffect Headers.main
    header <- TestHelpers.getHeader 8080 Object.empty "/" "X-Example"
    response <- TestHelpers.get 8080 (Object.singleton "X-Input" "test") "/"
    EffectClass.liftEffect $ close $ pure unit
    header ?= "hello world!"
    response ?= "test"

helloWorldSpec :: TestHelpers.Test
helloWorldSpec =
  Spec.it "runs the hello world example" do
    close <- EffectClass.liftEffect HelloWorld.main
    response <- TestHelpers.get 8080 Object.empty "/"
    EffectClass.liftEffect $ close $ pure unit
    response ?= "hello world!"

middlewareSpec :: TestHelpers.Test
middlewareSpec =
  Spec.it "runs the middleware example" do
    close <- EffectClass.liftEffect Middleware.main
    header <- TestHelpers.getHeader 8080 Object.empty "/" "X-Middleware"
    body <- TestHelpers.get 8080 Object.empty "/"
    header' <- TestHelpers.getHeader 8080 Object.empty "/middleware" "X-Middleware"
    body' <- TestHelpers.get 8080 Object.empty "/middleware"
    EffectClass.liftEffect $ close $ pure unit
    header ?= "router"
    body ?= "hello"
    header' ?= "middleware"
    body' ?= "Middleware!"

multiRouteSpec :: TestHelpers.Test
multiRouteSpec =
  Spec.it "runs the multi route example" do
    close <- EffectClass.liftEffect MultiRoute.main
    hello <- TestHelpers.get 8080 Object.empty "/hello"
    goodbye <- TestHelpers.get 8080 Object.empty "/goodbye"
    EffectClass.liftEffect $ close $ pure unit
    hello ?= "hello"
    goodbye ?= "goodbye"

pathSegmentsSpec :: TestHelpers.Test
pathSegmentsSpec =
  Spec.it "runs the path segments example" do
    close <- EffectClass.liftEffect PathSegments.main
    foo <- TestHelpers.get 8080 Object.empty "/segment/foo"
    somebars <- TestHelpers.get 8080 Object.empty "/some/bars"
    EffectClass.liftEffect $ close $ pure unit
    foo ?= "foo"
    somebars ?= "[\"some\",\"bars\"]"

postSpec :: TestHelpers.Test
postSpec =
  Spec.it "runs the post example" do
    close <- EffectClass.liftEffect Post.main
    response <- TestHelpers.post 8080 Object.empty "/" "test"
    EffectClass.liftEffect $ close $ pure unit
    response ?= "test"

queryParametersSpec :: TestHelpers.Test
queryParametersSpec =
  Spec.it "runs the query parameters example" do
    close <- EffectClass.liftEffect QueryParameters.main
    foo <- TestHelpers.get 8080 Object.empty "/?foo"
    bar <- TestHelpers.get 8080 Object.empty "/?bar=test"
    notbar <- TestHelpers.get 8080 Object.empty "/?bar=nottest"
    baz <- TestHelpers.get 8080 Object.empty "/?baz=test"
    EffectClass.liftEffect $ close $ pure unit
    foo ?= "foo"
    bar ?= "bar"
    notbar ?= ""
    baz ?= "test"

sslSpec :: TestHelpers.Test
sslSpec =
  Spec.it "runs the ssl example" do
    close <- EffectClass.liftEffect SSL.main
    response <- TestHelpers.get' 8080 Object.empty "/"
    EffectClass.liftEffect $ close $ pure unit
    response ?= "hello world!"

integrationSpec :: TestHelpers.Test
integrationSpec =
  Spec.describe "Integration" do
    asyncResponseSpec
    binarySpec
    chunkedSpec
    customStackSpec
    headersSpec
    helloWorldSpec
    middlewareSpec
    multiRouteSpec
    pathSegmentsSpec
    postSpec
    queryParametersSpec
    sslSpec
