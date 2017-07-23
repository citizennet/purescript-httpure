module HTTPure.Server
  ( ServerM
  , serve
  ) where

import Prelude

import Control.Monad.Aff as Aff
import Control.Monad.Eff.Class as EffClass
import Data.Maybe as Maybe
import Node.HTTP as HTTP

import HTTPure.HTTPureM as HTTPureM
import HTTPure.Request as Request
import HTTPure.Response as Response

-- | The ServerM type simply conveniently wraps up an HTTPure monad that
-- | returns a Unit. This type is the return type of the HTTPure serve and
-- | related methods.
type ServerM e = HTTPureM.HTTPureM e Unit

-- | This function takes a method which takes a request and returns a ResponseM,
-- | an HTTP request, and an HTTP response. It runs the request, extracts the
-- | Response from the ResponseM, and sends the Response to the HTTP Response.
handleRequest :: forall e.
                 (Request.Request -> Response.ResponseM e) ->
                 HTTP.Request ->
                 HTTP.Response ->
                 ServerM e
handleRequest router request response =
  void $ Aff.runAff (\_ -> pure unit) (\_ -> pure unit) do
    req <- Request.fromHTTPRequest request
    EffClass.liftEff $ router req >>= Response.send response

-- | Given an options object, a function mapping Request to ResponseM, and an
-- | HTTPureM containing effects to run on boot, creates and runs a HTTPure
-- | server.
boot :: forall e.
        HTTP.ListenOptions ->
        (Request.Request -> Response.ResponseM e) ->
        ServerM e ->
        ServerM e
boot options router onStarted =
  HTTP.createServer (handleRequest router) >>= \server ->
    HTTP.listen server options onStarted

-- | Create and start a server. This is the main entry point for HTTPure. Takes
-- | a port number on which to listen, a function mapping Request to ResponseM,
-- | and an HTTPureM containing effects to run after the server has booted
-- | (usually logging). Returns an HTTPureM containing the server's effects.
serve :: forall e.
         Int ->
         (Request.Request -> Response.ResponseM e) ->
         ServerM e ->
         ServerM e
serve port = boot
  { hostname: "localhost"
  , port: port
  , backlog: Maybe.Nothing
  }
