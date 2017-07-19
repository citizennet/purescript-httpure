module HTTPure.IntegrationSpec where

import Prelude

import Control.Monad.Eff.Class as EffClass
import Data.StrMap as StrMap
import Test.Spec as Spec

import HTTPure.SpecHelpers as SpecHelpers
import HTTPure.SpecHelpers ((?=))

import Headers as Headers
import HelloWorld as HelloWorld
import MultiRoute as MultiRoute
import Post as Post

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

postSpec :: SpecHelpers.Test
postSpec = Spec.it "runs the post example" do
  EffClass.liftEff Post.main
  response <- SpecHelpers.post port StrMap.empty "/" "test"
  response ?= "test"
  where port = Post.port

integrationSpec :: SpecHelpers.Test
integrationSpec = Spec.describe "Integration" do
  headersSpec
  helloWorldSpec
  multiRouteSpec
  postSpec
