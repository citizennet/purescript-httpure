module HTTPure.IntegrationSpec where

import Prelude (discard, bind)

import Control.Monad.Eff.Class as EffClass
import Test.Spec as Spec
import Test.Spec.Assertions as Assertions

import HTTPure.SpecHelpers as SpecHelpers

import HelloWorld as HelloWorld
import MultiRoute as MultiRoute
import Headers as Headers

helloWorldSpec :: SpecHelpers.Test
helloWorldSpec = Spec.it "runs the hello world example" do
  EffClass.liftEff HelloWorld.main
  response <- SpecHelpers.get "http://localhost:8080"
  response `Assertions.shouldEqual` "hello world!"

multiRouteSpec :: SpecHelpers.Test
multiRouteSpec = Spec.it "runs the multi route example" do
  EffClass.liftEff MultiRoute.main
  hello <- SpecHelpers.get "http://localhost:8081/hello"
  hello `Assertions.shouldEqual` "hello"
  goodbye <- SpecHelpers.get "http://localhost:8081/goodbye"
  goodbye `Assertions.shouldEqual` "goodbye"

headersSpec :: SpecHelpers.Test
headersSpec = Spec.it "runs the headers example" do
  EffClass.liftEff Headers.main
  header <- SpecHelpers.getHeader "http://localhost:8082" "X-Example"
  header `Assertions.shouldEqual` "hello world!"

integrationSpec :: SpecHelpers.Test
integrationSpec = Spec.describe "Integration" do
  helloWorldSpec
  multiRouteSpec
  headersSpec
