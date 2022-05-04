module Examples.PathSegments.Main where

import Prelude

import Effect.Console (log)
import HTTPure (Request, ResponseM, ServerM, ok, serve, (!@))

-- | Specify the routes
router :: Request -> ResponseM
router { path }
  | path !@ 0 == "segment" = ok $ path !@ 1
  | otherwise = ok $ show path

-- | Boot up the server
main :: ServerM
main =
  serve 8080 router do
    log " ┌───────────────────────────────────────────────┐"
    log " │ Server now up on port 8080                    │"
    log " │                                               │"
    log " │ To test, run:                                 │"
    log " │  > curl localhost:8080/segment/<anything>     │"
    log " │    # => <anything>                            │"
    log " │  > curl localhost:8080/<anything>/<else>/...  │"
    log " │    # => [ <anything>, <else>, ... ]           │"
    log " └───────────────────────────────────────────────┘"
