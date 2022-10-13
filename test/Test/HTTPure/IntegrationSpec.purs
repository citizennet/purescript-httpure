module Test.HTTPure.IntegrationSpec where

import Prelude

import Effect.Class (liftEffect)
import Examples.AsyncResponse.Main as AsyncResponse
import Examples.BinaryRequest.Main as BinaryRequest
import Examples.BinaryResponse.Main as BinaryResponse
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
import Foreign.Object (empty, singleton)
import Node.Buffer (toArray)
import Node.FS.Aff (readFile)
import Test.HTTPure.TestHelpers
  ( Test
  , get
  , get'
  , getBinary
  , getHeader
  , post
  , postBinary
  , (?=)
  )
import Test.Spec (describe, it)

asyncResponseSpec :: Test
asyncResponseSpec =
  it "runs the async response example" do
    close <- liftEffect AsyncResponse.main
    response <- get 8080 empty "/"
    liftEffect $ close $ pure unit
    response ?= "hello world!"

binaryRequestSpec :: Test
binaryRequestSpec =
  it "runs the binary request example" do
    close <- liftEffect BinaryRequest.main
    binaryBuf <- readFile BinaryResponse.filePath
    response <- postBinary 8080 empty "/" binaryBuf
    liftEffect $ close $ pure unit
    response ?= "d5e776724dd545d8b54123b46362a553d10257cee688ef1be62166c984b34405"

binaryResponseSpec :: Test
binaryResponseSpec =
  it "runs the binary response example" do
    close <- liftEffect BinaryResponse.main
    responseBuf <- getBinary 8080 empty "/"
    liftEffect $ close $ pure unit
    binaryBuf <- readFile BinaryResponse.filePath
    expected <- liftEffect $ toArray binaryBuf
    response <- liftEffect $ toArray responseBuf
    response ?= expected

chunkedSpec :: Test
chunkedSpec =
  it "runs the chunked example" do
    close <- liftEffect Chunked.main
    response <- get 8080 empty "/"
    liftEffect $ close $ pure unit
    -- TODO this isn't a great way to validate this, we need a way of inspecting
    -- each individual chunk instead of just looking at the entire response
    response ?= "hello \nworld!\n"

customStackSpec :: Test
customStackSpec =
  it "runs the custom stack example" do
    close <- liftEffect CustomStack.main
    response <- get 8080 empty "/"
    liftEffect $ close $ pure unit
    response ?= "hello, joe"

headersSpec :: Test
headersSpec =
  it "runs the headers example" do
    close <- liftEffect Headers.main
    header <- getHeader 8080 empty "/" "X-Example"
    response <- get 8080 (singleton "X-Input" "test") "/"
    liftEffect $ close $ pure unit
    header ?= "hello world!"
    response ?= "test"

helloWorldSpec :: Test
helloWorldSpec =
  it "runs the hello world example" do
    close <- liftEffect HelloWorld.main
    response <- get 8080 empty "/"
    liftEffect $ close $ pure unit
    response ?= "hello world!"

middlewareSpec :: Test
middlewareSpec =
  it "runs the middleware example" do
    close <- liftEffect Middleware.main
    header <- getHeader 8080 empty "/" "X-Middleware"
    body <- get 8080 empty "/"
    header' <- getHeader 8080 empty "/middleware" "X-Middleware"
    body' <- get 8080 empty "/middleware"
    liftEffect $ close $ pure unit
    header ?= "router"
    body ?= "hello"
    header' ?= "middleware"
    body' ?= "Middleware!"

multiRouteSpec :: Test
multiRouteSpec =
  it "runs the multi route example" do
    close <- liftEffect MultiRoute.main
    hello <- get 8080 empty "/hello"
    goodbye <- get 8080 empty "/goodbye"
    liftEffect $ close $ pure unit
    hello ?= "hello"
    goodbye ?= "goodbye"

pathSegmentsSpec :: Test
pathSegmentsSpec =
  it "runs the path segments example" do
    close <- liftEffect PathSegments.main
    foo <- get 8080 empty "/segment/foo"
    somebars <- get 8080 empty "/some/bars"
    liftEffect $ close $ pure unit
    foo ?= "foo"
    somebars ?= "[\"some\",\"bars\"]"

postSpec :: Test
postSpec =
  it "runs the post example" do
    close <- liftEffect Post.main
    response <- post 8080 empty "/" "test"
    liftEffect $ close $ pure unit
    response ?= "test"

queryParametersSpec :: Test
queryParametersSpec =
  it "runs the query parameters example" do
    close <- liftEffect QueryParameters.main
    foo <- get 8080 empty "/?foo"
    bar <- get 8080 empty "/?bar=test"
    notbar <- get 8080 empty "/?bar=nottest"
    baz <- get 8080 empty "/?baz=test"
    liftEffect $ close $ pure unit
    foo ?= "foo"
    bar ?= "bar"
    notbar ?= ""
    baz ?= "test"

sslSpec :: Test
sslSpec =
  it "runs the ssl example" do
    close <- liftEffect SSL.main
    response <- get' 8080 empty "/"
    liftEffect $ close $ pure unit
    response ?= "hello world!"

integrationSpec :: Test
integrationSpec =
  describe "Integration" do
    asyncResponseSpec
    binaryRequestSpec
    binaryResponseSpec
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
