module Examples.Chunked.Main where

import Prelude

import Effect.Class as EffectClass
import Effect.Console as Console
import HTTPure as HTTPure
import Node.ChildProcess as ChildProcess

-- | Serve the example server on this port
port :: Int
port = 8091

-- | Shortcut for `show port`
portS :: String
portS = show port

-- | This is the script that says hello!
script :: String
script = "echo -n 'hello '; sleep 1; echo -n 'world!'"

-- | Say 'hello world!' in chunks when run
sayHello :: HTTPure.Request -> HTTPure.ResponseM
sayHello _ = do
  child <- EffectClass.liftEffect $
    ChildProcess.spawn "sh" [ "-c", script ] ChildProcess.defaultSpawnOptions
  HTTPure.ok $ ChildProcess.stdout $ child

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
