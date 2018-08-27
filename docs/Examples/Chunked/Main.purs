module Examples.Chunked.Main where

import Prelude

import Effect.Console as Console
import HTTPure as HTTPure
import Node.Stream as Stream

-- | Serve the example server on this port
port :: Int
port = 8091

-- | Shortcut for `show port`
portS :: String
portS = show port

-- | Return a readable stream that emits the first string, then the second
-- | string, with a delay in between given by the third argument
foreign import stagger :: String -> String -> Int -> Stream.Readable ()

-- | Say 'hello world!' in chunks when run
sayHello :: HTTPure.Request -> HTTPure.ResponseM
sayHello _ = HTTPure.ok $ HTTPure.Chunked $ stagger "hello " "world!" 1000

-- | Boot up the server
main :: HTTPure.ServerM
main = HTTPure.serve port sayHello do
  Console.log $ " ┌────────────────────────────────────────────┐"
  Console.log $ " │ Server now up on port " <> portS <> "                 │"
  Console.log $ " │                                            │"
  Console.log $ " │ To test, run:                              │"
  Console.log $ " │  > curl -Nv localhost:" <> portS <> "                 │"
  Console.log $ " │    # => ...                                │"
  Console.log $ " │    # => < Transfer-Encoding: chunked       │"
  Console.log $ " │    # => ...                                │"
  Console.log $ " │    # => hello                              │"
  Console.log $ " │    (1 second pause)                        │"
  Console.log $ " │    # => world!                             │"
  Console.log $ " └────────────────────────────────────────────┘"
