module HTTPure.IntegrationSpec where

import Prelude

import Control.Monad.Eff.Class as EffClass
import Data.StrMap as StrMap
import Test.Spec as Spec

import HTTPure.SpecHelpers as SpecHelpers
import HTTPure.SpecHelpers ((?=))

import AsyncResponse as AsyncResponse
import Headers as Headers
import HelloWorld as HelloWorld
import MultiRoute as MultiRoute
import PathSegments as PathSegments
import QueryParameters as QueryParameters
import Post as Post
import SSL as SSL

asyncResponseSpec :: SpecHelpers.Test
asyncResponseSpec = Spec.it "runs the async response example" do
  EffClass.liftEff AsyncResponse.main
  response <- SpecHelpers.get port StrMap.empty "/"
  response ?= "hello world!"
  where port = AsyncResponse.port

headersSpec :: SpecHelpers.Test
headersSpec = Spec.it "runs the headers example" do
  EffClass.liftEff Headers.main
  header <- SpecHelpers.getHeader port StrMap.empty "/" "X-Example"
  header ?= "hello world!"
  response <- SpecHelpers.get port (StrMap.singleton "X-Input" "test") "/"
  response ?= "test"
  where port = Headers.port

helloWorldSpec :: SpecHelpers.Test
helloWorldSpec = Spec.it "runs the hello world example" do
  EffClass.liftEff HelloWorld.main
  response <- SpecHelpers.get port StrMap.empty "/"
  response ?= "hello world!"
  where port = HelloWorld.port

multiRouteSpec :: SpecHelpers.Test
multiRouteSpec = Spec.it "runs the multi route example" do
  EffClass.liftEff MultiRoute.main
  hello <- SpecHelpers.get port StrMap.empty "/hello"
  hello ?= "hello"
  goodbye <- SpecHelpers.get port StrMap.empty "/goodbye"
  goodbye ?= "goodbye"
  where port = MultiRoute.port

pathSegmentsSpec :: SpecHelpers.Test
pathSegmentsSpec = Spec.it "runs the path segments example" do
  EffClass.liftEff PathSegments.main
  foo <- SpecHelpers.get port StrMap.empty "/segment/foo"
  foo ?= "foo"
  somebars <- SpecHelpers.get port StrMap.empty "/some/bars"
  somebars ?= "[\"some\",\"bars\"]"
  where port = PathSegments.port

queryParametersSpec :: SpecHelpers.Test
queryParametersSpec = Spec.it "runs the query parameters example" do
  EffClass.liftEff QueryParameters.main
  foo <- SpecHelpers.get port StrMap.empty "/?foo"
  foo ?= "foo"
  bar <- SpecHelpers.get port StrMap.empty "/?bar=test"
  bar ?= "bar"
  notbar <- SpecHelpers.get port StrMap.empty "/?bar=nottest"
  notbar ?= ""
  baz <- SpecHelpers.get port StrMap.empty "/?baz=test"
  baz ?= "test"
  where port = QueryParameters.port

postSpec :: SpecHelpers.Test
postSpec = Spec.it "runs the post example" do
  EffClass.liftEff Post.main
  response <- SpecHelpers.post port StrMap.empty "/" "test"
  response ?= "test"
  where port = Post.port

sslSpec :: SpecHelpers.Test
sslSpec = Spec.it "runs the ssl example" do
  EffClass.liftEff SSL.main
  response <- SpecHelpers.get' port StrMap.empty "/"
  response ?= "hello world!"
  where port = SSL.port

integrationSpec :: SpecHelpers.Test
integrationSpec = Spec.describe "Integration" do
  asyncResponseSpec
  headersSpec
  helloWorldSpec
  multiRouteSpec
  pathSegmentsSpec
  queryParametersSpec
  postSpec
  sslSpec
