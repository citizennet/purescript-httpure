module Examples.MultiRoute.Main where

import Prelude
import Effect.Console (log)
import HTTPure (Request, ResponseM, ServerM, serve, ok, notFound)

-- | Specify the routes
router :: Request -> ResponseM
router { path: [ "hello" ] } = ok "hello"
router { path: [ "goodbye" ] } = ok "goodbye"
router _ = notFound

-- | Boot up the server
main :: ServerM
main =
  serve 8080 router do
    log " ┌────────────────────────────────┐"
    log " │ Server now up on port 8080     │"
    log " │                                │"
    log " │ To test, run:                  │"
    log " │  > curl localhost:8080/hello   │"
    log " │    # => hello                  │"
    log " │  > curl localhost:8080/goodbye │"
    log " │    # => goodbye                │"
    log " └────────────────────────────────┘"
