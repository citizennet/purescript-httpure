module Examples.Middleware.Main where

import Prelude

import Effect.Class (liftEffect)
import Effect.Console (log)
import HTTPure (Request, ResponseM, ServerM, fullPath, header, ok, ok', serve)

-- | A middleware that logs at the beginning and end of each request
loggingMiddleware ::
  (Request -> ResponseM) ->
  Request ->
  ResponseM
loggingMiddleware router request = do
  liftEffect $ log $ "Request starting for " <> path
  response <- router request
  liftEffect $ log $ "Request ending for " <> path
  pure response
  where
  path = fullPath request

-- | A middleware that adds the X-Middleware header to the response, if it
-- | wasn't already in the response
headerMiddleware ::
  (Request -> ResponseM) ->
  Request ->
  ResponseM
headerMiddleware router request = do
  response@{ headers } <- router request
  pure $ response { headers = header' <> headers }
  where
  header' = header "X-Middleware" "middleware"

-- | A middleware that sends the body "Middleware!" instead of running the
-- | router when requesting /middleware
pathMiddleware ::
  (Request -> ResponseM) ->
  Request ->
  ResponseM
pathMiddleware _ { path: [ "middleware" ] } = ok "Middleware!"
pathMiddleware router request = router request

-- | Say 'hello' when run, and add a default value to the X-Middleware header
sayHello :: Request -> ResponseM
sayHello _ = ok' (header "X-Middleware" "router") "hello"

-- | The stack of middlewares to use for the server
middlewareStack :: (Request -> ResponseM) -> Request -> ResponseM
middlewareStack = loggingMiddleware <<< headerMiddleware <<< pathMiddleware

-- | Boot up the server
main :: ServerM
main =
  serve 8080 (middlewareStack sayHello) do
    log " ┌───────────────────────────────────────┐"
    log " │ Server now up on port 8080            │"
    log " │                                       │"
    log " │ To test, run:                         │"
    log " │  > curl -v localhost:8080             │"
    log " │    # => ...                           │"
    log " │    # => ...< X-Middleware: router     │"
    log " │    # => ...                           │"
    log " │    # => hello                         │"
    log " │  > curl -v localhost:8080/middleware  │"
    log " │    # => ...                           │"
    log " │    # => ...< X-Middleware: middleware │"
    log " │    # => ...                           │"
    log " │    # => Middleware!                   │"
    log " └───────────────────────────────────────┘"
