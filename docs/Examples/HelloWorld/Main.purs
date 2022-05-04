module Examples.HelloWorld.Main where

import Prelude

import Effect.Console (log)
import HTTPure (ServerM, ok, serve)

-- | Boot up the server
main :: ServerM
main =
  serve 8080 (const $ ok "hello world!") do
    log " ┌────────────────────────────────────────────┐"
    log " │ Server now up on port 8080                 │"
    log " │                                            │"
    log " │ To test, run:                              │"
    log " │  > curl localhost:8080   # => hello world! │"
    log " └────────────────────────────────────────────┘"
