module Middleware where

import Prelude

import Control.Monad.Eff.Class as EffClass
import Control.Monad.Eff.Console as Console
import HTTPure as HTTPure

-- | Serve the example server on this port
port :: Int
port = 8089

-- | Shortcut for `show port`
portS :: String
portS = show port

-- | A middleware that logs at the beginning and end of each request
loggingMiddleware :: forall e.
                     (HTTPure.Request ->
                      HTTPure.ResponseM (console :: Console.CONSOLE | e)) ->
                     HTTPure.Request ->
                     HTTPure.ResponseM (console :: Console.CONSOLE | e)
loggingMiddleware router request = do
  EffClass.liftEff $ Console.log $ "Request starting for " <> path
  response <- router request
  EffClass.liftEff $ Console.log $ "Request ending for " <> path
  pure response
  where
    path = HTTPure.fullPath request

-- | A middleware that adds the X-Middleware header to the response, if it
-- | wasn't already in the response
headerMiddleware :: forall e.
                    (HTTPure.Request -> HTTPure.ResponseM e) ->
                    HTTPure.Request ->
                    HTTPure.ResponseM e
headerMiddleware router request = do
  response <- router request
  HTTPure.response' response.status (header <> response.headers) response.body
  where
    header = HTTPure.header "X-Middleware" "middleware"

-- | A middleware that sends the body "Middleware!" instead of running the
-- | router when requesting /middleware
pathMiddleware :: forall e.
                  (HTTPure.Request -> HTTPure.ResponseM e) ->
                  HTTPure.Request ->
                  HTTPure.ResponseM e
pathMiddleware _ { path: [ "middleware" ] } = HTTPure.ok "Middleware!"
pathMiddleware router request = router request

-- | Say 'hello' when run, and add a default value to the X-Middleware header
sayHello :: forall e. HTTPure.Request -> HTTPure.ResponseM e
sayHello _ = HTTPure.ok' (HTTPure.header "X-Middleware" "router") "hello"

-- | Boot up the server
main :: forall e. HTTPure.ServerM (console :: Console.CONSOLE | e)
main = HTTPure.serve port (middlewares sayHello) do
  Console.log $ " ┌───────────────────────────────────────┐"
  Console.log $ " │ Server now up on port " <> portS <> "            │"
  Console.log $ " │                                       │"
  Console.log $ " │ To test, run:                         │"
  Console.log $ " │  > curl -v localhost:" <> portS <> "             │"
  Console.log $ " │    # => ...                           │"
  Console.log $ " │    # => ...< X-Middleware: router     │"
  Console.log $ " │    # => ...                           │"
  Console.log $ " │    # => hello                         │"
  Console.log $ " │  > curl -v localhost:" <> portS <> "/middleware  │"
  Console.log $ " │    # => ...                           │"
  Console.log $ " │    # => ...< X-Middleware: middleware │"
  Console.log $ " │    # => ...                           │"
  Console.log $ " │    # => Middleware!                   │"
  Console.log $ " └───────────────────────────────────────┘"
  where
    middlewares = loggingMiddleware <<< headerMiddleware <<< pathMiddleware
