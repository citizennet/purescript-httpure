module Examples.SSL.Main where

import Prelude

import Effect.Console as Console
import HTTPure as HTTPure

-- | The path to the certificate file
cert :: String
cert = "./docs/Examples/SSL/Certificate.cer"

-- | The path to the key file
key :: String
key = "./docs/Examples/SSL/Key.key"

-- | Say 'hello world!' when run
sayHello :: HTTPure.Request -> HTTPure.ResponseM
sayHello _ = HTTPure.ok "hello world!"

-- | Boot up the server
main :: HTTPure.ServerM
main = HTTPure.serveSecure 8080 cert key sayHello do
  Console.log $ " ┌───────────────────────────────────────────┐"
  Console.log $ " │ Server now up on port 8080                │"
  Console.log $ " │                                           │"
  Console.log $ " │ To test, run:                             │"
  Console.log $ " │  > curl --insecure https://localhost:8080 │"
  Console.log $ " │    # => hello world!                      │"
  Console.log $ " └───────────────────────────────────────────┘"
