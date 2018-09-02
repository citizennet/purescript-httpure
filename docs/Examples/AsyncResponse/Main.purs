module Examples.AsyncResponse.Main where

import Prelude

import Effect.Console as Console
import HTTPure as HTTPure
import Node.Encoding as Encoding
import Node.FS.Aff as FSAff

-- | The path to the file containing the response to send
filePath :: String
filePath = "./docs/Examples/AsyncResponse/Hello"

-- | Say 'hello world!' when run
sayHello :: HTTPure.Request -> HTTPure.ResponseM
sayHello = const $ FSAff.readTextFile Encoding.UTF8 filePath >>= HTTPure.ok

-- | Boot up the server
main :: HTTPure.ServerM
main = HTTPure.serve 8080 sayHello do
  Console.log $ " ┌────────────────────────────────────────────┐"
  Console.log $ " │ Server now up on port 8080                 │"
  Console.log $ " │                                            │"
  Console.log $ " │ To test, run:                              │"
  Console.log $ " │  > curl localhost:8080   # => hello world! │"
  Console.log $ " └────────────────────────────────────────────┘"
