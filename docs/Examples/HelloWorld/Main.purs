module Examples.HelloWorld.Main where

import Prelude
import Effect.Console as Console
import HTTPure as HTTPure

-- | Boot up the server
main :: HTTPure.ServerM
main =
  HTTPure.serve 8080 (const $ HTTPure.ok "hello world!") do
    Console.log $ " ┌────────────────────────────────────────────┐"
    Console.log $ " │ Server now up on port 8080                 │"
    Console.log $ " │                                            │"
    Console.log $ " │ To test, run:                              │"
    Console.log $ " │  > curl localhost:8080   # => hello world! │"
    Console.log $ " └────────────────────────────────────────────┘"
