module Examples.PathSegments.Main where

import Prelude
import Effect.Console as Console
import HTTPure as HTTPure
import HTTPure ((!@))

-- | Specify the routes
router :: HTTPure.Request -> HTTPure.ResponseM
router { path }
  | path !@ 0 == "segment" = HTTPure.ok $ path !@ 1
  | otherwise = HTTPure.ok $ show path

-- | Boot up the server
main :: HTTPure.ServerM
main =
  HTTPure.serve 8080 router do
    Console.log $ " ┌───────────────────────────────────────────────┐"
    Console.log $ " │ Server now up on port 8080                    │"
    Console.log $ " │                                               │"
    Console.log $ " │ To test, run:                                 │"
    Console.log $ " │  > curl localhost:8080/segment/<anything>     │"
    Console.log $ " │    # => <anything>                            │"
    Console.log $ " │  > curl localhost:8080/<anything>/<else>/...  │"
    Console.log $ " │    # => [ <anything>, <else>, ... ]           │"
    Console.log $ " └───────────────────────────────────────────────┘"
