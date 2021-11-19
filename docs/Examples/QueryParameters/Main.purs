module Examples.QueryParameters.Main where

import Prelude
import Effect.Console (log)
import HTTPure as HTTPure
import HTTPure (Request, ResponseM, ServerM, (!@), (!?), serve, ok)

-- | Specify the routes
router :: Request -> ResponseM
router { query }
  | query !? "foo" = ok "foo"
  | query !@ "bar" == "test" = ok "bar"
  | otherwise = ok $ query !@ "baz"

-- | Boot up the server
main :: ServerM
main =
  serve 8080 router do
    log " ┌───────────────────────────────────────┐"
    log " │ Server now up on port 8080            │"
    log " │                                       │"
    log " │ To test, run:                         │"
    log " │  > curl localhost:8080?foo            │"
    log " │    # => foo                           │"
    log " │  > curl localhost:8080?bar=test       │"
    log " │    # => bar                           │"
    log " │  > curl localhost:8080?baz=<anything> │"
    log " │    # => <anything>                    │"
    log " └───────────────────────────────────────┘"
