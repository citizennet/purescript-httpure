module Examples.BinaryResponse.Main where

import Prelude
import Effect.Console (log)
import Node.FS.Aff (readFile)
import HTTPure (ServerM, Request, ResponseM, ResponseHeaders, serve, ok', header)

-- | The path to the file containing the response to send
filePath :: String
filePath = "./docs/Examples/BinaryResponse/circle.png"

responseHeaders :: ResponseHeaders
responseHeaders = header "Content-Type" "image/png"

-- | Respond with image data when run
image :: Request -> ResponseM
image = const $ readFile filePath >>= ok' responseHeaders

-- | Boot up the server
main :: ServerM
main =
  serve 8080 image do
    log " ┌──────────────────────────────────────┐"
    log " │ Server now up on port 8080           │"
    log " │                                      │"
    log " │ To test, run:                        │"
    log " │  > curl -o circle.png localhost:8080 │"
    log " └──────────────────────────────────────┘"
