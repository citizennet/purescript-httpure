module Examples.MultiRoute.Main where

import Prelude

import Effect.Console as Console
import HTTPure as HTTPure

-- | Specify the routes
router :: HTTPure.Request -> HTTPure.ResponseM
router { path: [ "hello" ] }   = HTTPure.ok "hello"
router { path: [ "goodbye" ] } = HTTPure.ok "goodbye"
router _                       = HTTPure.notFound

-- | Boot up the server
main :: HTTPure.ServerM
main = HTTPure.serve 8080 router do
  Console.log $ " ┌───────────────────────────────────────────────┐"
  Console.log $ " │ Server now up on port 8080                    │"
  Console.log $ " │                                               │"
  Console.log $ " │ To test, run:                                 │"
  Console.log $ " │  > curl localhost:8080/hello     # => hello   │"
  Console.log $ " │  > curl localhost:8080/goodbye   # => goodbye │"
  Console.log $ " └───────────────────────────────────────────────┘"
