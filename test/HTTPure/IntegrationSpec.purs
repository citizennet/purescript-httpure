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
  header <- SpecHelpers.getHeader 8082 StrMap.empty "/" "X-Example"
  header ?= "hello world!"
  response <- SpecHelpers.get 8082 (StrMap.singleton "X-Input" "test") "/"
  response ?= "test"

helloWorldSpec :: SpecHelpers.Test
helloWorldSpec = Spec.it "runs the hello world example" do
  EffClass.liftEff HelloWorld.main
  response <- SpecHelpers.get 8080 StrMap.empty "/"
  response ?= "hello world!"

multiRouteSpec :: SpecHelpers.Test
multiRouteSpec = Spec.it "runs the multi route example" do
  EffClass.liftEff MultiRoute.main
  hello <- SpecHelpers.get 8081 StrMap.empty "/hello"
  hello ?= "hello"
  goodbye <- SpecHelpers.get 8081 StrMap.empty "/goodbye"
  goodbye ?= "goodbye"

postSpec :: SpecHelpers.Test
postSpec = Spec.it "runs the post example" do
  EffClass.liftEff Post.main
  response <- SpecHelpers.post 8084 StrMap.empty "/" "test"
  response ?= "test"

integrationSpec :: SpecHelpers.Test
integrationSpec = Spec.describe "Integration" do
  headersSpec
  helloWorldSpec
  multiRouteSpec
  postSpec
