module HTTPure.ServerSpec where

import Prelude (bind, discard, pure, unit, ($))

import Control.Monad.Eff.Class as EffClass
import Data.Maybe as Maybe
import Node.Encoding as Encoding
import Node.StreamBuffer as StreamBuffer
import Test.Spec as Spec
import Test.Spec.Assertions as Assertions

import HTTPure.SpecHelpers as SpecHelpers

import HTTPure.Server as Server
import HTTPure.Route as Route

routes :: forall e. Array (Route.Route e)
routes =
  [ Route.Get "/test1"
    { status: \_ -> 200
    , headers: \_ -> []
    , body: \_ -> "test1"
    }
  , Route.Get "/test2"
    { status: \_ -> 200
    , headers: \_ -> []
    , body: \_ -> "test2"
    }
  ]

handleRequestSpec :: SpecHelpers.Test
handleRequestSpec = Spec.describe "handleRequest" $
  Spec.it "matches and runs a route" do
    body <- EffClass.liftEff do
      buf <- StreamBuffer.writable
      Server.handleRequest routes mockRequest $ SpecHelpers.mockHTTPResponse buf
      StreamBuffer.contents Encoding.UTF8 buf
    body `Assertions.shouldEqual` "test1"
  where
    mockRequest = SpecHelpers.mockHTTPRequest "/test1"

bootSpec :: SpecHelpers.Test
bootSpec = Spec.describe "boot" $
  Spec.it "boots a server with the given options" do
    EffClass.liftEff $ Server.boot options routes $ pure unit
    out <- SpecHelpers.get "http://localhost:7900/test1"
    out `Assertions.shouldEqual` "test1"
  where
    options = { port: 7900, hostname: "localhost", backlog: Maybe.Nothing }

serveSpec :: SpecHelpers.Test
serveSpec = Spec.describe "serve" $
  Spec.it "boots a server on the given port" do
    EffClass.liftEff $ Server.serve 7901 routes $ pure unit
    out <- SpecHelpers.get "http://localhost:7901/test2"
    out `Assertions.shouldEqual` "test2"

serverSpec :: SpecHelpers.Test
serverSpec = Spec.describe "Server" do
  handleRequestSpec
  bootSpec
  serveSpec
