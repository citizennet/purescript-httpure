module HTTPure.Server
  ( ServerM
  , serve
  , serve'
  , serveSecure
  , serveSecure'
  ) where

import Prelude

import Effect as Effect
import Effect.Aff as Aff
import Effect.Class as EffectClass
import Effect.Console as Console
import Data.Maybe as Maybe
import Data.Options ((:=), Options)
import Node.Encoding as Encoding
import Node.FS.Sync as FSSync
import Node.HTTP as HTTP
import Node.HTTP.Secure as HTTPS

import HTTPure.Request as Request
import HTTPure.Response as Response

-- | The `ServerM` is just an `Effect` containing a callback to close the
-- | server. This type is the return type of the HTTPure serve and related
-- | methods.
type ServerM = Effect.Effect (Effect.Effect Unit -> Effect.Effect Unit)

-- | Given a router, handle unhandled exceptions it raises by
-- | responding with 500 Internal Server Error.
onError500 :: (Request.Request -> Response.ResponseM) ->
              Request.Request ->
              Response.ResponseM
onError500 router request =
  Aff.catchError (router request) \err -> do
    EffectClass.liftEffect $ Console.error $ Aff.message err
    Response.internalServerError "Internal server error"


-- | This function takes a method which takes a `Request` and returns a
-- | `ResponseM`, an HTTP `Request`, and an HTTP `Response`. It runs the
-- | request, extracts the `Response` from the `ResponseM`, and sends the
-- | `Response` to the HTTP `Response`.
handleRequest :: (Request.Request -> Response.ResponseM) ->
                 HTTP.Request ->
                 HTTP.Response ->
                 Effect.Effect Unit
handleRequest router request httpresponse =
  void $ Aff.runAff (\_ -> pure unit) $
    Request.fromHTTPRequest request
    >>= onError500 router
    >>= Response.send httpresponse

-- | Given a `ListenOptions` object, a function mapping `Request` to
-- | `ResponseM`, and a `ServerM` containing effects to run on boot, creates and
-- | runs a HTTPure server without SSL.
serve' :: HTTP.ListenOptions ->
          (Request.Request -> Response.ResponseM) ->
          Effect.Effect Unit ->
          ServerM
serve' options router onStarted = do
  server <- HTTP.createServer (handleRequest router)
  HTTP.listen server options onStarted
  pure $ HTTP.close server

-- | Given a `Options HTTPS.SSLOptions` object and a `HTTP.ListenOptions`
-- | object, a function mapping `Request` to `ResponseM`, and a `ServerM`
-- | containing effects to run on boot, creates and runs a HTTPure server with
-- | SSL.
serveSecure' :: Options HTTPS.SSLOptions ->
                HTTP.ListenOptions ->
                (Request.Request -> Response.ResponseM) ->
                Effect.Effect Unit ->
                ServerM
serveSecure' sslOptions options router onStarted = do
  server <- HTTPS.createServer sslOptions (handleRequest router)
  HTTP.listen server options onStarted
  pure $ HTTP.close server

-- | Given a port number, return a `HTTP.ListenOptions` `Record`.
listenOptions :: Int -> HTTP.ListenOptions
listenOptions port =
  { hostname: "0.0.0.0"
  , port: port
  , backlog: Maybe.Nothing
  }

-- | Create and start a server. This is the main entry point for HTTPure. Takes
-- | a port number on which to listen, a function mapping `Request` to
-- | `ResponseM`, and a `ServerM` containing effects to run after the server has
-- | booted (usually logging). Returns an `ServerM` containing the server's
-- | effects.
serve :: Int ->
         (Request.Request -> Response.ResponseM) ->
         Effect.Effect Unit ->
         ServerM
serve = serve' <<< listenOptions

-- | Create and start an SSL server. This method is the same as `serve`, but
-- | takes additional SSL arguments.  The arguments in order are:
-- | 1. A port number
-- | 2. A path to a cert file
-- | 3. A path to a private key file
-- | 4. A handler method which maps `Request` to `ResponseM`
-- | 5. A callback to call when the server is up
serveSecure :: Int ->
               String ->
               String ->
               (Request.Request -> Response.ResponseM) ->
               Effect.Effect Unit ->
               ServerM
serveSecure port cert key router onStarted = do
  cert' <- FSSync.readTextFile Encoding.UTF8 cert
  key' <- FSSync.readTextFile Encoding.UTF8 key
  serveSecure' (sslOpts key' cert') (listenOptions port) router onStarted
  where
    sslOpts key' cert' =
      HTTPS.key  := HTTPS.keyString  key' <>
      HTTPS.cert := HTTPS.certString cert'
