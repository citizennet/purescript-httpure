module Test.HTTPure.ServerSpec where

import Prelude
import Effect.Class as EffectClass
import Effect.Exception as Exception
import Control.Monad.Except as Except
import Data.Maybe as Maybe
import Data.Options ((:=))
import Data.String as String
import Foreign.Object as Object
import Node.Encoding as Encoding
import Node.HTTP.Secure as HTTPS
import Node.FS.Sync as FSSync
import Test.Spec as Spec
import Test.Spec.Assertions as Assertions
import HTTPure.Request as Request
import HTTPure.Response as Response
import HTTPure.Server as Server
import Test.HTTPure.TestHelpers as TestHelpers
import Test.HTTPure.TestHelpers ((?=))

mockRouter :: Request.Request -> Response.ResponseM
mockRouter { path } = Response.ok $ "/" <> String.joinWith "/" path

errorRouter :: Request.Request -> Response.ResponseM
errorRouter _ = Except.throwError $ Exception.error "fail!"

serveSpec :: TestHelpers.Test
serveSpec =
  Spec.describe "serve" do
    Spec.it "boots a server on the given port" do
      close <- EffectClass.liftEffect $ Server.serve 8080 mockRouter $ pure unit
      out <- TestHelpers.get 8080 Object.empty "/test"
      EffectClass.liftEffect $ close $ pure unit
      out ?= "/test"
    Spec.it "responds with a 500 upon unhandled exceptions" do
      close <- EffectClass.liftEffect $ Server.serve 8080 errorRouter $ pure unit
      status <- TestHelpers.getStatus 8080 Object.empty "/"
      EffectClass.liftEffect $ close $ pure unit
      status ?= 500

serve'Spec :: TestHelpers.Test
serve'Spec =
  Spec.describe "serve'" do
    Spec.it "boots a server with the given options" do
      close <-
        EffectClass.liftEffect
          $ Server.serve' options mockRouter
          $ pure unit
      out <- TestHelpers.get 8080 Object.empty "/test"
      EffectClass.liftEffect $ close $ pure unit
      out ?= "/test"
  where
  options = { hostname: "localhost", port: 8080, backlog: Maybe.Nothing }

serveSecureSpec :: TestHelpers.Test
serveSecureSpec =
  Spec.describe "serveSecure" do
    Spec.describe "with valid key and cert files" do
      Spec.it "boots a server on the given port" do
        close <-
          EffectClass.liftEffect
            $ Server.serveSecure 8080 cert key mockRouter
            $ pure unit
        out <- TestHelpers.get' 8080 Object.empty "/test"
        EffectClass.liftEffect $ close $ pure unit
        out ?= "/test"
    Spec.describe "with invalid key and cert files" do
      Spec.it "throws" do
        Assertions.expectError $ EffectClass.liftEffect
          $ Server.serveSecure 8080 "" "" mockRouter
          $ pure unit
  where
  cert = "./test/Mocks/Certificate.cer"

  key = "./test/Mocks/Key.key"

serveSecure'Spec :: TestHelpers.Test
serveSecure'Spec =
  Spec.describe "serveSecure'" do
    Spec.describe "with valid key and cert files" do
      Spec.it "boots a server on the given port" do
        sslOpts <- EffectClass.liftEffect $ sslOptions
        close <-
          EffectClass.liftEffect
            $ Server.serveSecure' sslOpts (options 8080) mockRouter
            $ pure unit
        out <- TestHelpers.get' 8080 Object.empty "/test"
        EffectClass.liftEffect $ close $ pure unit
        out ?= "/test"
  where
  options port = { hostname: "localhost", port, backlog: Maybe.Nothing }

  sslOptions = do
    cert <- FSSync.readTextFile Encoding.UTF8 "./test/Mocks/Certificate.cer"
    key <- FSSync.readTextFile Encoding.UTF8 "./test/Mocks/Key.key"
    pure
      $ HTTPS.key
      := HTTPS.keyString key
      <> HTTPS.cert
      := HTTPS.certString cert

serverSpec :: TestHelpers.Test
serverSpec =
  Spec.describe "Server" do
    serveSpec
    serve'Spec
    serveSecureSpec
    serveSecure'Spec
