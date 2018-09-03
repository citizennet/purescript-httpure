module Examples.Chunked.Main where

import Prelude

import Effect.Aff as Aff
import Effect.Class as EffectClass
import Effect.Console as Console
import HTTPure as HTTPure
import Node.ChildProcess as ChildProcess
import Node.Stream as Stream

-- | Run a script and return it's stdout stream
runScript :: String -> Aff.Aff (Stream.Readable ())
runScript script = EffectClass.liftEffect $ ChildProcess.stdout <$>
  ChildProcess.spawn "sh" [ "-c", script ] ChildProcess.defaultSpawnOptions

-- | Say 'hello world!' in chunks when run
sayHello :: HTTPure.Request -> HTTPure.ResponseM
sayHello =
  const $ runScript "echo -n 'hello '; sleep 1; echo -n 'world!'" >>= HTTPure.ok

-- | Boot up the server
main :: HTTPure.ServerM
main = HTTPure.serve 8080 sayHello do
  Console.log $ " ┌──────────────────────────────────────┐"
  Console.log $ " │ Server now up on port 8080           │"
  Console.log $ " │                                      │"
  Console.log $ " │ To test, run:                        │"
  Console.log $ " │  > curl -Nv localhost:8080           │"
  Console.log $ " │    # => ...                          │"
  Console.log $ " │    # => < Transfer-Encoding: chunked │"
  Console.log $ " │    # => ...                          │"
  Console.log $ " │    # => hello                        │"
  Console.log $ " │    (1 second pause)                  │"
  Console.log $ " │    # => world!                       │"
  Console.log $ " └──────────────────────────────────────┘"
