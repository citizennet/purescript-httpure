module Examples.SSL.Main where

import Prelude
import Effect.Console (log)
import HTTPure (Request, ResponseM, ServerM, serveSecure, ok)

-- | The path to the certificate file
cert :: String
cert = "./docs/Examples/SSL/Certificate.cer"

-- | The path to the key file
key :: String
key = "./docs/Examples/SSL/Key.key"

-- | Say 'hello world!' when run
sayHello :: Request -> ResponseM
sayHello _ = ok "hello world!"

-- | Boot up the server
main :: ServerM
main =
  serveSecure 8080 cert key sayHello do
    log " ┌───────────────────────────────────────────┐"
    log " │ Server now up on port 8080                │"
    log " │                                           │"
    log " │ To test, run:                             │"
    log " │  > curl --insecure https://localhost:8080 │"
    log " │    # => hello world!                      │"
    log " └───────────────────────────────────────────┘"
