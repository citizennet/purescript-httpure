module Examples.BinaryRequest.Main where

import Prelude
import Effect.Console (log)
import HTTPure (Request, ResponseM, ServerM, ok, serve)
import HTTPure.Request (readBodyAsBuffer)
import Node.Buffer (Buffer)

foreign import sha256sum :: Buffer -> String

-- | Respond with file's sha256sum
router :: Request -> ResponseM
router request = readBodyAsBuffer request >>= sha256sum >>> ok

-- | Boot up the server
main :: ServerM
main =
  serve 8080 router do
    log " ┌─────────────────────────────────────────────────────────┐"
    log " │ Server now up on port 8080                              │"
    log " │                                                         │"
    log " │ To test, run:                                           │"
    log " │  > curl -XPOST --data-binary @circle.png localhost:8080 │"
    log " │                          # => d5e776724dd5...           │"
    log " └─────────────────────────────────────────────────────────┘"
