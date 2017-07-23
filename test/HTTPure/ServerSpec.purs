module HTTPure.ServerSpec where

import Prelude

import Control.Monad.Eff.Class as EffClass
import Data.StrMap as StrMap
import Test.Spec as Spec
import Test.Spec.Assertions.Aff as AffAssertions

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

serve'Spec :: SpecHelpers.Test
serve'Spec = Spec.describe "serve" do
  Spec.describe "with valid key and cert files" do
    Spec.it "boots a server on the given port" do
      EffClass.liftEff $ Server.serve' 7902 cert key mockRouter $ pure unit
      out <- SpecHelpers.get' 7902 StrMap.empty "/test"
      out ?= "/test"
  Spec.describe "with invalid key and cert files" do
    Spec.it "throws" do
      AffAssertions.expectError do
        EffClass.liftEff $ Server.serve' 7903 "" "" mockRouter $ pure unit
  where
    cert = "./test/Mocks/Certificate.cer"
    key = "./test/Mocks/Key.key"

serverSpec :: SpecHelpers.Test
serverSpec = Spec.describe "Server" do
  serveSpec
  serve'Spec
