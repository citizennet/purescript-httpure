module Examples.AsyncResponse.Main where

import Prelude

import Effect.Console (log)
import HTTPure (Request, ResponseM, ServerM, ok, serve)
import Node.Encoding (Encoding(UTF8))
import Node.FS.Aff (readTextFile)

-- | The path to the file containing the response to send
filePath :: String
filePath = "./docs/Examples/AsyncResponse/Hello"

-- | Say 'hello world!' when run
sayHello :: Request -> ResponseM
sayHello = const $ readTextFile UTF8 filePath >>= ok

-- | Boot up the server
main :: ServerM
main =
  serve 8080 sayHello do
    log " ┌────────────────────────────────────────────┐"
    log " │ Server now up on port 8080                 │"
    log " │                                            │"
    log " │ To test, run:                              │"
    log " │  > curl localhost:8080   # => hello world! │"
    log " └────────────────────────────────────────────┘"
