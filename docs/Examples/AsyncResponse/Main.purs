module Examples.AsyncResponse.Main where

import Prelude

import Effect.Console as Console
import HTTPure as HTTPure
import Node.Encoding as Encoding
import Node.FS.Aff as FSAff

-- | Serve the example server on this port
port :: Int
port = 8088

-- | Shortcut for `show port`
portS :: String
portS = show port

-- | The path to the file containing the response to send
filePath :: String
filePath = "./docs/Examples/AsyncResponse/Hello"

-- | Say 'hello world!' when run
sayHello :: HTTPure.Request -> HTTPure.ResponseM
sayHello _ = FSAff.readTextFile Encoding.UTF8 filePath >>= HTTPure.ok

-- | Boot up the server
main :: HTTPure.ServerM
main = HTTPure.serve port sayHello do
  Console.log $ " ┌────────────────────────────────────────────┐"
  Console.log $ " │ Server now up on port " <> portS <> "                 │"
  Console.log $ " │                                            │"
  Console.log $ " │ To test, run:                              │"
  Console.log $ " │  > curl localhost:" <> portS <> "   # => hello world! │"
  Console.log $ " └────────────────────────────────────────────┘"
