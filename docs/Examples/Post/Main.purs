module Examples.Post.Main where

import Prelude
import Effect.Console as Console
import HTTPure as HTTPure

-- | Route to the correct handler
router :: HTTPure.Request -> HTTPure.ResponseM
router { body, method: HTTPure.Post } = HTTPure.toString body >>= HTTPure.ok
router _ = HTTPure.notFound

-- | Boot up the server
main :: HTTPure.ServerM
main =
  HTTPure.serve 8080 router do
    Console.log $ " ┌───────────────────────────────────────────┐"
    Console.log $ " │ Server now up on port 8080                │"
    Console.log $ " │                                           │"
    Console.log $ " │ To test, run:                             │"
    Console.log $ " │  > curl -XPOST --data test localhost:8080 │"
    Console.log $ " │    # => test                              │"
    Console.log $ " └───────────────────────────────────────────┘"
