module Test.HTTPure.ServerSpec where

import Prelude
import Effect.Class (liftEffect)
import Effect.Exception (error)
import Control.Monad.Except (throwError)
import Data.Maybe (Maybe(Nothing))
import Data.Options ((:=))
import Data.String (joinWith)
import Foreign.Object (empty)
import Node.Encoding (Encoding(UTF8))
import Node.HTTP.Secure (key, keyString, cert, certString)
import Node.FS.Sync (readTextFile)
import Test.Spec (describe, it)
import Test.Spec.Assertions (expectError)
import HTTPure.Request (Request)
import HTTPure.Response (ResponseM, ok)
import HTTPure.Server (serve, serve', serveSecure, serveSecure')
import Test.HTTPure.TestHelpers (Test, (?=), get, get', getStatus)

mockRouter :: Request -> ResponseM
mockRouter { path } = ok $ "/" <> joinWith "/" path

serveSpec :: Test
serveSpec =
  describe "serve" do
    it "boots a server on the given port" do
      close <- liftEffect $ serve 8080 mockRouter $ pure unit
      out <- get 8080 empty "/test"
      liftEffect $ close $ pure unit
      out ?= "/test"
    it "responds with a 500 upon unhandled exceptions" do
      let router _ = throwError $ error "fail!"
      close <- liftEffect $ serve 8080 router $ pure unit
      status <- getStatus 8080 empty "/"
      liftEffect $ close $ pure unit
      status ?= 500

serve'Spec :: Test
serve'Spec =
  describe "serve'" do
    it "boots a server with the given options" do
      let options = { hostname: "localhost", port: 8080, backlog: Nothing }
      close <-
        liftEffect
          $ serve' options mockRouter
          $ pure unit
      out <- get 8080 empty "/test"
      liftEffect $ close $ pure unit
      out ?= "/test"

serveSecureSpec :: Test
serveSecureSpec =
  describe "serveSecure" do
    describe "with valid key and cert files" do
      it "boots a server on the given port" do
        close <-
          liftEffect
            $ serveSecure 8080 "./test/Mocks/Certificate.cer" "./test/Mocks/Key.key" mockRouter
            $ pure unit
        out <- get' 8080 empty "/test"
        liftEffect $ close $ pure unit
        out ?= "/test"
    describe "with invalid key and cert files" do
      it "throws" do
        expectError $ liftEffect
          $ serveSecure 8080 "" "" mockRouter
          $ pure unit

serveSecure'Spec :: Test
serveSecure'Spec =
  describe "serveSecure'" do
    describe "with valid key and cert files" do
      it "boots a server on the given port" do
        let
          options = { hostname: "localhost", port: 8080, backlog: Nothing }
          sslOptions = do
            cert' <- readTextFile UTF8 "./test/Mocks/Certificate.cer"
            key' <- readTextFile UTF8 "./test/Mocks/Key.key"
            pure $ key := keyString key' <> cert := certString cert'
        sslOpts <- liftEffect $ sslOptions
        close <-
          liftEffect
            $ serveSecure' sslOpts options mockRouter
            $ pure unit
        out <- get' 8080 empty "/test"
        liftEffect $ close $ pure unit
        out ?= "/test"

serverSpec :: Test
serverSpec =
  describe "Server" do
    serveSpec
    serve'Spec
    serveSecureSpec
    serveSecure'Spec
