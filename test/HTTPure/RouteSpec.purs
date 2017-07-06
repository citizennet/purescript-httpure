module HTTPure.RouteSpec where

import Prelude (bind, discard, eq, flip, show, ($))

import Control.Monad.Eff.Class as EffClass
import Data.Maybe as Maybe
import Node.Encoding as Encoding
import Node.StreamBuffer as StreamBuffer
import Test.Spec as Spec
import Test.Spec.Assertions as Assertions

import HTTPure.SpecHelpers as SpecHelpers

import HTTPure.Route as Route

hooks :: forall e. Route.RouteHooks e
hooks = { body: \_ -> "", headers: \_ -> [], status: \_ -> 200 }

showSpec :: SpecHelpers.Test
showSpec = Spec.describe "show" do
  Spec.describe "with a Get route on /test" $
    Spec.it "is 'GET: /test'" $
      show (Route.Get "/test" hooks) `Assertions.shouldEqual` "GET: /test"
  Spec.describe "with a Post route on /test" $
    Spec.it "is 'POST: /test" $
      show (Route.Post "/test" hooks) `Assertions.shouldEqual` "POST: /test"
  Spec.describe "with a Put route on /test" $
    Spec.it "is 'PUT /test" $
      show (Route.Put "/test" hooks) `Assertions.shouldEqual` "PUT: /test"
  Spec.describe "with a Delete route on /test" $
    Spec.it "is 'DELETE: /test" $
      show (Route.Delete "/test" hooks) `Assertions.shouldEqual` "DELETE: /test"

eqSpec :: SpecHelpers.Test
eqSpec = Spec.describe "eq" do
  Spec.describe "with routes with the same method and same match patterns" $
    Spec.it "is true" $
      route1 `eq` route2 `Assertions.shouldEqual` true
  Spec.describe "with routes with different match patterns" $
    Spec.it "is false" $
      route1 `eq` route3 `Assertions.shouldEqual` false
  Spec.describe "with routes with different methods" $
    Spec.it "is false" $
      route1 `eq` route4 `Assertions.shouldEqual` false
  where
    route1 = Route.Get "a" hooks
    route2 = Route.Get "a" hooks
    route3 = Route.Get "b" hooks
    route4 = Route.Put "a" hooks

runSpec :: SpecHelpers.Test
runSpec = Spec.describe "run" $
  Spec.it "writes the body" do
    body <- EffClass.liftEff do
      buf <- StreamBuffer.writable
      run $ SpecHelpers.mockResponse buf
      StreamBuffer.contents Encoding.UTF8 buf
    body `Assertions.shouldEqual` "test"
  where
    run resp = Route.run testRoute (SpecHelpers.mockRequest "/") resp
    testRoute = Route.Get "/"
      { body: \_ -> "test"
      , headers: \_ -> []
      , status: \_ -> 200
      }

isMatchSpec :: SpecHelpers.Test
isMatchSpec = Spec.describe "isMatch" do
  Spec.describe "when the route is a match" $
    Spec.it "is true" $
      isMatch (SpecHelpers.mockRequest "test") `Assertions.shouldEqual` true
  Spec.describe "when the route is not a match" $
    Spec.it "is false" $
      isMatch (SpecHelpers.mockRequest "test2") `Assertions.shouldEqual` false
  where
    isMatch = Route.isMatch route
    route = Route.Get "test" hooks

matchSpec :: SpecHelpers.Test
matchSpec = Spec.describe "match" do
  Spec.describe "when a matching route exists" $
    Spec.it "is Just the matching route" $
      match [ route1, route2 ] `Assertions.shouldEqual` Maybe.Just route1
  Spec.describe "when a matching route does not exist" $
    Spec.it "is Nothing" $
      match [ route2 ] `Assertions.shouldEqual` Maybe.Nothing
  where
    match = (flip Route.match) (SpecHelpers.mockRequest "1")
    route1 = Route.Get "1" hooks
    route2 = Route.Get "2" hooks

routeSpec :: SpecHelpers.Test
routeSpec = Spec.describe "Route" do
  showSpec
  eqSpec
  runSpec
  isMatchSpec
  matchSpec
