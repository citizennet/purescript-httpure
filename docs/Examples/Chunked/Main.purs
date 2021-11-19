module Examples.Chunked.Main where

import Prelude
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Console (log)
import HTTPure (ServerM, Request, ResponseM, serve, ok)
import Node.ChildProcess (stdout, spawn, defaultSpawnOptions)
import Node.Stream (Readable)

-- | Run a script and return it's stdout stream
runScript :: String -> Aff (Readable ())
runScript script =
  liftEffect $ stdout <$> spawn "sh" [ "-c", script ] defaultSpawnOptions

-- | Say 'hello world!' in chunks when run
sayHello :: Request -> ResponseM
sayHello = const $ runScript "echo 'hello '; sleep 1; echo 'world!'" >>= ok

-- | Boot up the server
main :: ServerM
main =
  serve 8080 sayHello do
    log " ┌──────────────────────────────────────┐"
    log " │ Server now up on port 8080           │"
    log " │                                      │"
    log " │ To test, run:                        │"
    log " │  > curl -Nv localhost:8080           │"
    log " │    # => ...                          │"
    log " │    # => < Transfer-Encoding: chunked │"
    log " │    # => ...                          │"
    log " │    # => hello                        │"
    log " │    (1 second pause)                  │"
    log " │    # => world!                       │"
    log " └──────────────────────────────────────┘"
