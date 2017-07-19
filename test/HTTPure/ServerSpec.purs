module HTTPure.ServerSpec where

import Prelude

import Control.Monad.Eff.Class as EffClass
import Data.StrMap as StrMap
import Test.Spec as Spec

import HTTPure.Request as Request
import HTTPure.Response as Response
import HTTPure.Server as Server

import HTTPure.SpecHelpers as SpecHelpers
import HTTPure.SpecHelpers ((?=))

mockRouter :: forall e. Request.Request -> Response.ResponseM e
mockRouter (Request.Get _ path) = pure $ Response.OK StrMap.empty path
mockRouter _                    = pure $ Response.OK StrMap.empty ""

serveSpec :: SpecHelpers.Test
serveSpec = Spec.describe "serve" do
  Spec.it "boots a server on the given port" do
    EffClass.liftEff $ Server.serve 7901 mockRouter $ pure unit
    out <- SpecHelpers.get 7901 StrMap.empty "/test"
    out ?= "/test"

serverSpec :: SpecHelpers.Test
serverSpec = Spec.describe "Server" do
  serveSpec
