module Examples.Post.Main where

import Prelude

import Effect.Console as Console
import HTTPure as HTTPure

-- | Serve the example server on this port
port :: Int
port = 8084

-- | Shortcut for `show port`
portS :: String
portS = show port

-- | Route to the correct handler
router :: HTTPure.Request -> HTTPure.ResponseM
router { body, method: HTTPure.Post } = HTTPure.ok body
router _                              = HTTPure.notFound

-- | Boot up the server
main :: HTTPure.ServerM
main = HTTPure.serve port router do
  Console.log $ " ┌───────────────────────────────────────────┐"
  Console.log $ " │ Server now up on port " <> portS <> "                │"
  Console.log $ " │                                           │"
  Console.log $ " │ To test, run:                             │"
  Console.log $ " │  > curl -XPOST --data test localhost:" <> portS <> " │"
  Console.log $ " │    # => test                              │"
  Console.log $ " └───────────────────────────────────────────┘"
