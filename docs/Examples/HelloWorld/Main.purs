module Examples.HelloWorld.Main where

import Prelude

import Effect.Console as Console
import HTTPure as HTTPure

-- | Serve the example server on this port
port :: Int
port = 8080

-- | Shortcut for `show port`
portS :: String
portS = show port

-- | Say 'hello world!' when run
sayHello :: HTTPure.Request -> HTTPure.ResponseM
sayHello _ = HTTPure.ok "hello world!"

-- | Boot up the server
main :: HTTPure.ServerM
main = HTTPure.serve port sayHello do
  Console.log $ " ┌────────────────────────────────────────────┐"
  Console.log $ " │ Server now up on port " <> portS <> "                 │"
  Console.log $ " │                                            │"
  Console.log $ " │ To test, run:                              │"
  Console.log $ " │  > curl localhost:" <> portS <> "   # => hello world! │"
  Console.log $ " └────────────────────────────────────────────┘"
