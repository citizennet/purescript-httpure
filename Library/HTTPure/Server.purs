module HTTPure.Server
  ( boot,
    handleRequest,
    serve
  ) where

import Prelude (pure, unit, (>>=))

import Data.Maybe as Maybe
import Node.HTTP as HTTP

import HTTPure.HTTPureM as HTTPureM
import HTTPure.Request as Request
import HTTPure.Response as Response
import HTTPure.Route as Route

-- | This function takes an array of Routes, a request, and a response, and
-- | routes the request to the correct Routes. After the Routes have run, this
-- | function closes the request stream.
handleRequest :: forall e.
                 Array (Route.Route e) ->
                 HTTP.Request ->
                 HTTP.Response ->
                 HTTPureM.HTTPureM e
handleRequest routes request response =
  case Route.match routes req of
    Maybe.Just route -> Route.run route req resp
    Maybe.Nothing -> pure unit
  where
    req = Request.fromHTTPRequest request
    resp = Response.fromHTTPResponse response

-- | Given an options object, an Array of Routes, and an HTTPureM containing
-- | effects to run on boot, creates and runs a HTTPure server.
boot :: forall e.
        HTTP.ListenOptions ->
        Array (Route.Route e) ->
        HTTPureM.HTTPureM e ->
        HTTPureM.HTTPureM e
boot options routes onStarted =
  HTTP.createServer (handleRequest routes) >>= \server ->
    HTTP.listen server options onStarted

-- | Create and start a server. This is the main entry point for HTTPure. Takes
-- | a port number on which to listen, an Array of Routes to serve, and an
-- | HTTPureM containing effects to run after the server has booted (usually
-- | logging). Returns an HTTPureM containing the server's effects.
serve :: forall e.
         Int ->
         Array (Route.Route e) ->
         HTTPureM.HTTPureM e ->
         HTTPureM.HTTPureM e
serve port = boot
  { hostname: "localhost"
  , port: port
  , backlog: Maybe.Nothing
  }
