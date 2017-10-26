module Test.HTTPure.IntegrationSpec where

import Prelude

import Control.Monad.Eff.Class as EffClass
import Data.StrMap as StrMap
import Test.Spec as Spec

import Test.HTTPure.TestHelpers as TestHelpers
import Test.HTTPure.TestHelpers ((?=))

import Examples.AsyncResponse.Main as AsyncResponse
import Examples.Headers.Main as Headers
import Examples.HelloWorld.Main as HelloWorld
import Examples.Middleware.Main as Middleware
import Examples.MultiRoute.Main as MultiRoute
import Examples.PathSegments.Main as PathSegments
import Examples.QueryParameters.Main as QueryParameters
import Examples.Post.Main as Post
import Examples.SSL.Main as SSL

asyncResponseSpec :: TestHelpers.Test
asyncResponseSpec = Spec.it "runs the async response example" do
  EffClass.liftEff AsyncResponse.main
  response <- TestHelpers.get port StrMap.empty "/"
  response ?= "hello world!"
  where port = AsyncResponse.port

headersSpec :: TestHelpers.Test
headersSpec = Spec.it "runs the headers example" do
  EffClass.liftEff Headers.main
  header <- TestHelpers.getHeader port StrMap.empty "/" "X-Example"
  header ?= "hello world!"
  response <- TestHelpers.get port (StrMap.singleton "X-Input" "test") "/"
  response ?= "test"
  where port = Headers.port

helloWorldSpec :: TestHelpers.Test
helloWorldSpec = Spec.it "runs the hello world example" do
  EffClass.liftEff HelloWorld.main
  response <- TestHelpers.get port StrMap.empty "/"
  response ?= "hello world!"
  where port = HelloWorld.port

middlewareSpec :: TestHelpers.Test
middlewareSpec = Spec.it "runs the middleware example" do
  EffClass.liftEff Middleware.main
  header <- TestHelpers.getHeader port StrMap.empty "/" "X-Middleware"
  header ?= "router"
  body <- TestHelpers.get port StrMap.empty "/"
  body ?= "hello"
  header <- TestHelpers.getHeader port StrMap.empty "/middleware" "X-Middleware"
  header ?= "middleware"
  body' <- TestHelpers.get port StrMap.empty "/middleware"
  body' ?= "Middleware!"
  where port = Middleware.port

multiRouteSpec :: TestHelpers.Test
multiRouteSpec = Spec.it "runs the multi route example" do
  EffClass.liftEff MultiRoute.main
  hello <- TestHelpers.get port StrMap.empty "/hello"
  hello ?= "hello"
  goodbye <- TestHelpers.get port StrMap.empty "/goodbye"
  goodbye ?= "goodbye"
  where port = MultiRoute.port

pathSegmentsSpec :: TestHelpers.Test
pathSegmentsSpec = Spec.it "runs the path segments example" do
  EffClass.liftEff PathSegments.main
  foo <- TestHelpers.get port StrMap.empty "/segment/foo"
  foo ?= "foo"
  somebars <- TestHelpers.get port StrMap.empty "/some/bars"
  somebars ?= "[\"some\",\"bars\"]"
  where port = PathSegments.port

queryParametersSpec :: TestHelpers.Test
queryParametersSpec = Spec.it "runs the query parameters example" do
  EffClass.liftEff QueryParameters.main
  foo <- TestHelpers.get port StrMap.empty "/?foo"
  foo ?= "foo"
  bar <- TestHelpers.get port StrMap.empty "/?bar=test"
  bar ?= "bar"
  notbar <- TestHelpers.get port StrMap.empty "/?bar=nottest"
  notbar ?= ""
  baz <- TestHelpers.get port StrMap.empty "/?baz=test"
  baz ?= "test"
  where port = QueryParameters.port

postSpec :: TestHelpers.Test
postSpec = Spec.it "runs the post example" do
  EffClass.liftEff Post.main
  response <- TestHelpers.post port StrMap.empty "/" "test"
  response ?= "test"
  where port = Post.port

sslSpec :: TestHelpers.Test
sslSpec = Spec.it "runs the ssl example" do
  EffClass.liftEff SSL.main
  response <- TestHelpers.get' port StrMap.empty "/"
  response ?= "hello world!"
  where port = SSL.port

integrationSpec :: TestHelpers.Test
integrationSpec = Spec.describe "Integration" do
  asyncResponseSpec
  headersSpec
  helloWorldSpec
  middlewareSpec
  multiRouteSpec
  pathSegmentsSpec
  queryParametersSpec
  postSpec
  sslSpec
