module HTTPure.Server
  ( ServerM
  , serve
  , serve'
  , serveSecure
  , serveSecure'
  ) where

import Prelude
import Effect (Effect)
import Effect.Aff (catchError, runAff, message)
import Effect.Class (liftEffect)
import Effect.Console (error)
import Data.Maybe (Maybe(Nothing))
import Data.Options ((:=), Options)
import Node.Encoding (Encoding(UTF8))
import Node.FS.Sync (readTextFile)
import Node.HTTP (Request, Response, createServer) as HTTP
import Node.HTTP (ListenOptions, listen, close)
import Node.HTTP.Secure (createServer) as HTTPS
import Node.HTTP.Secure (SSLOptions, key, keyString, cert, certString)
import HTTPure.Request (Request, fromHTTPRequest)
import HTTPure.Response (ResponseM, internalServerError, send)

-- | The `ServerM` is just an `Effect` containing a callback to close the
-- | server. This type is the return type of the HTTPure serve and related
-- | methods.
type ServerM = Effect (Effect Unit -> Effect Unit)

-- | Given a router, handle unhandled exceptions it raises by
-- | responding with 500 Internal Server Error.
onError500 :: (Request -> ResponseM) -> Request -> ResponseM
onError500 router request =
  catchError (router request) \err -> do
    liftEffect $ error $ message err
    internalServerError "Internal server error"

-- | This function takes a method which takes a `Request` and returns a
-- | `ResponseM`, an HTTP `Request`, and an HTTP `Response`. It runs the
-- | request, extracts the `Response` from the `ResponseM`, and sends the
-- | `Response` to the HTTP `Response`.
handleRequest ::
  (Request -> ResponseM) ->
  HTTP.Request ->
  HTTP.Response ->
  Effect Unit
handleRequest router request httpresponse =
  void $ runAff (\_ -> pure unit) $ fromHTTPRequest request
    >>= onError500 router
    >>= send httpresponse

-- | Given a `ListenOptions` object, a function mapping `Request` to
-- | `ResponseM`, and a `ServerM` containing effects to run on boot, creates and
-- | runs a HTTPure server without SSL.
serve' :: ListenOptions -> (Request -> ResponseM) -> Effect Unit -> ServerM
serve' options router onStarted = do
  server <- HTTP.createServer (handleRequest router)
  listen server options onStarted
  pure $ close server

-- | Given a `Options HTTPS.SSLOptions` object and a `HTTP.ListenOptions`
-- | object, a function mapping `Request` to `ResponseM`, and a `ServerM`
-- | containing effects to run on boot, creates and runs a HTTPure server with
-- | SSL.
serveSecure' ::
  Options SSLOptions ->
  ListenOptions ->
  (Request -> ResponseM) ->
  Effect Unit ->
  ServerM
serveSecure' sslOptions options router onStarted = do
  server <- HTTPS.createServer sslOptions (handleRequest router)
  listen server options onStarted
  pure $ close server

-- | Given a port number, return a `HTTP.ListenOptions` `Record`.
listenOptions :: Int -> ListenOptions
listenOptions port =
  { hostname: "0.0.0.0"
  , port
  , backlog: Nothing
  }

-- | Create and start a server. This is the main entry point for HTTPure. Takes
-- | a port number on which to listen, a function mapping `Request` to
-- | `ResponseM`, and a `ServerM` containing effects to run after the server has
-- | booted (usually logging). Returns an `ServerM` containing the server's
-- | effects.
serve :: Int -> (Request -> ResponseM) -> Effect Unit -> ServerM
serve = serve' <<< listenOptions

-- | Create and start an SSL server. This method is the same as `serve`, but
-- | takes additional SSL arguments.  The arguments in order are:
-- | 1. A port number
-- | 2. A path to a cert file
-- | 3. A path to a private key file
-- | 4. A handler method which maps `Request` to `ResponseM`
-- | 5. A callback to call when the server is up
serveSecure ::
  Int ->
  String ->
  String ->
  (Request -> ResponseM) ->
  Effect Unit ->
  ServerM
serveSecure port certFile keyFile router onStarted = do
  cert' <- readTextFile UTF8 certFile
  key' <- readTextFile UTF8 keyFile
  let sslOpts = key := keyString key' <> cert := certString cert'
  serveSecure' sslOpts (listenOptions port) router onStarted
