module Test.HTTPure.ServerSpec where

import Prelude

import Control.Monad.Eff.Class as EffClass
import Data.String as String
import Data.StrMap as StrMap
import Test.Spec as Spec
import Test.Spec.Assertions.Aff as AffAssertions

import HTTPure.Request as Request
import HTTPure.Response as Response
import HTTPure.Server as Server

import Test.HTTPure.TestHelpers as TestHelpers
import Test.HTTPure.TestHelpers ((?=))

mockRouter :: forall e. Request.Request -> Response.ResponseM e
mockRouter { path } = Response.ok $ "/" <> String.joinWith "/" path

serveSpec :: TestHelpers.Test
serveSpec = Spec.describe "serve" do
  Spec.it "boots a server on the given port" do
    EffClass.liftEff $ Server.serve 7901 mockRouter $ pure unit
    out <- TestHelpers.get 7901 StrMap.empty "/test"
    out ?= "/test"

serve'Spec :: TestHelpers.Test
serve'Spec = Spec.describe "serve" do
  Spec.describe "with valid key and cert files" do
    Spec.it "boots a server on the given port" do
      EffClass.liftEff $ Server.serve' 7902 cert key mockRouter $ pure unit
      out <- TestHelpers.get' 7902 StrMap.empty "/test"
      out ?= "/test"
  Spec.describe "with invalid key and cert files" do
    Spec.it "throws" do
      AffAssertions.expectError do
        EffClass.liftEff $ Server.serve' 7903 "" "" mockRouter $ pure unit
  where
    cert = "./test/Mocks/Certificate.cer"
    key = "./test/Mocks/Key.key"

serverSpec :: TestHelpers.Test
serverSpec = Spec.describe "Server" do
  serveSpec
  serve'Spec
