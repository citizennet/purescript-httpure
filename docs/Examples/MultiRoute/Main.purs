module Examples.MultiRoute.Main where

import Prelude

import Effect.Console as Console
import HTTPure as HTTPure

-- | Serve the example server on this port
port :: Int
port = 8081

-- | Shortcut for `show port`
portS :: String
portS = show port

-- | Specify the routes
router :: HTTPure.Request -> HTTPure.ResponseM
router { path: [ "hello" ] }   = HTTPure.ok "hello"
router { path: [ "goodbye" ] } = HTTPure.ok "goodbye"
router _                       = HTTPure.notFound

-- | Boot up the server
main :: HTTPure.ServerM
main = HTTPure.serve port router do
  Console.log $ " ┌───────────────────────────────────────────────┐"
  Console.log $ " │ Server now up on port " <> portS <> "                    │"
  Console.log $ " │                                               │"
  Console.log $ " │ To test, run:                                 │"
  Console.log $ " │  > curl localhost:" <> portS <> "/hello     # => hello   │"
  Console.log $ " │  > curl localhost:" <> portS <> "/goodbye   # => goodbye │"
  Console.log $ " └───────────────────────────────────────────────┘"
