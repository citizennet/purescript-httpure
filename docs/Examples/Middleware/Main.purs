module Examples.Middleware.Main where

import Prelude

import Effect.Class as EffectClass
import Effect.Console as Console
import HTTPure as HTTPure

-- | Serve the example server on this port
port :: Int
port = 8089

-- | Shortcut for `show port`
portS :: String
portS = show port

-- | A middleware that logs at the beginning and end of each request
loggingMiddleware :: (HTTPure.Request -> HTTPure.ResponseM) ->
                     HTTPure.Request ->
                     HTTPure.ResponseM
loggingMiddleware router request = do
  EffectClass.liftEffect $ Console.log $ "Request starting for " <> path
  response <- router request
  EffectClass.liftEffect $ Console.log $ "Request ending for " <> path
  pure response
  where
    path = HTTPure.fullPath request

-- | A middleware that adds the X-Middleware header to the response, if it
-- | wasn't already in the response
headerMiddleware :: (HTTPure.Request -> HTTPure.ResponseM) ->
                    HTTPure.Request ->
                    HTTPure.ResponseM
headerMiddleware router request = do
  { status, headers, body } <- router request
  pure $ { status, headers: header <> headers, body}
  where
    header = HTTPure.header "X-Middleware" "middleware"

-- | A middleware that sends the body "Middleware!" instead of running the
-- | router when requesting /middleware
pathMiddleware :: (HTTPure.Request -> HTTPure.ResponseM) ->
                  HTTPure.Request ->
                  HTTPure.ResponseM
pathMiddleware _ { path: [ "middleware" ] } = HTTPure.ok "Middleware!"
pathMiddleware router request = router request

-- | Say 'hello' when run, and add a default value to the X-Middleware header
sayHello :: HTTPure.Request -> HTTPure.ResponseM
sayHello _ = HTTPure.ok' (HTTPure.header "X-Middleware" "router") "hello"

-- | Boot up the server
main :: HTTPure.ServerM
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
