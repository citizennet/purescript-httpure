module HTTPure.ServerSpec where

import Prelude (bind, discard, pure, unit, ($))

import Control.Monad.Eff.Class as EffClass
import Data.Maybe as Maybe
import Node.Encoding as Encoding
import Node.StreamBuffer as StreamBuffer
import Data.StrMap as StrMap
import Test.Spec as Spec
import Test.Spec.Assertions as Assertions

import HTTPure.Request as Request
import HTTPure.Response as Response
import HTTPure.Server as Server

import HTTPure.SpecHelpers as SpecHelpers

mockRouter :: forall e. Request.Request -> Response.ResponseM e
mockRouter (Request.Get _ path) = pure $ Response.OK StrMap.empty path
mockRouter _                    = pure $ Response.OK StrMap.empty ""

handleRequestSpec :: SpecHelpers.Test
handleRequestSpec = Spec.describe "handleRequest" do
  Spec.it "runs the router and writes the response" do
    body <- EffClass.liftEff do
      buf <- StreamBuffer.writable
      Server.handleRequest mockRouter mockRequest $ SpecHelpers.mockResponse buf
      StreamBuffer.contents Encoding.UTF8 buf
    body `Assertions.shouldEqual` "test1"
  where
    mockRequest = SpecHelpers.mockRequest "GET" "test1"

bootSpec :: SpecHelpers.Test
bootSpec = Spec.describe "boot" do
  Spec.it "boots a server with the given options" do
    EffClass.liftEff $ Server.boot options mockRouter $ pure unit
    out <- SpecHelpers.get "http://localhost:7900/test1"
    out `Assertions.shouldEqual` "/test1"
  where
    options = { port: 7900, hostname: "localhost", backlog: Maybe.Nothing }

serveSpec :: SpecHelpers.Test
serveSpec = Spec.describe "serve" do
  Spec.it "boots a server on the given port" do
    EffClass.liftEff $ Server.serve 7901 mockRouter $ pure unit
    out <- SpecHelpers.get "http://localhost:7901/test2"
    out `Assertions.shouldEqual` "/test2"

serverSpec :: SpecHelpers.Test
serverSpec = Spec.describe "Server" do
  handleRequestSpec
  bootSpec
  serveSpec
