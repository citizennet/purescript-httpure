module HTTPure.Server
  ( ServerM
  , serve
  , serve'
  ) where

import Prelude

import Control.Monad.Aff as Aff
import Control.Monad.Eff.Class as EffClass
import Data.Maybe as Maybe
import Data.Options ((:=))
import Node.Encoding as Encoding
import Node.FS.Sync as FSSync
import Node.HTTP as HTTP
import Node.HTTP.Secure as HTTPS

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

-- | Given a ListenOptions Record, a function mapping Request to ResponseM, and
-- | an HTTPureM containing effects to run on boot, creates and runs a HTTPure
-- | server without SSL.
bootHTTP :: forall e.
            HTTP.ListenOptions ->
            (Request.Request -> Response.ResponseM e) ->
            ServerM e ->
            ServerM e
bootHTTP options router onStarted =
  HTTP.createServer (handleRequest router) >>= \server ->
    HTTP.listen server options onStarted

-- | Given a ListenOptions Record, a path to a cert file, a path to a private
-- | key file, a function mapping Request to ResponseM, and an HTTPureM
-- | containing effects to run on boot, creates and runs a HTTPure server with
-- | SSL.
bootHTTPS :: forall e.
             HTTP.ListenOptions ->
             String ->
             String ->
             (Request.Request -> Response.ResponseM  e) ->
             ServerM e ->
             ServerM e
bootHTTPS options cert key router onStarted = do
  cert' <- FSSync.readTextFile Encoding.UTF8 cert
  key' <- FSSync.readTextFile Encoding.UTF8 key
  server <- HTTPS.createServer (sslOpts key' cert') (handleRequest router)
  HTTP.listen server options onStarted
  where
    sslOpts key' cert' =
      HTTPS.key  := HTTPS.keyString  key' <>
      HTTPS.cert := HTTPS.certString cert'

-- | Given a port number, return a HTTP.ListenOptions Record.
listenOptions :: Int -> HTTP.ListenOptions
listenOptions port =
  { hostname: "localhost"
  , port: port
  , backlog: Maybe.Nothing
  }

-- | Create and start a server. This is the main entry point for HTTPure. Takes
-- | a port number on which to listen, a function mapping Request to ResponseM,
-- | and an HTTPureM containing effects to run after the server has booted
-- | (usually logging). Returns an HTTPureM containing the server's effects.
serve :: forall e.
         Int ->
         (Request.Request -> Response.ResponseM e) ->
         ServerM e ->
         ServerM e
serve = bootHTTP <<< listenOptions

-- | Create and start an SSL server. This method is the same as `serve`, but
-- | takes additional SSL arguments.  The arguments in order are:
-- | 1. A port number
-- | 2. A path to a cert file
-- | 3. A path to a private key file
-- | 4. A handler method which maps Request to ResponseM
-- | 5. A callback to call when the server is up
serve' :: forall e.
          Int ->
          String ->
          String ->
          (Request.Request -> Response.ResponseM e) ->
          ServerM e ->
          ServerM e
serve' = bootHTTPS <<< listenOptions
