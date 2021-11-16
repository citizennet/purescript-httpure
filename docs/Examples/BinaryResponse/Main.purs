module Examples.BinaryResponse.Main where

import Prelude
import Effect.Console as Console
import Node.FS.Aff as FS
import HTTPure as HTTPure

-- | The path to the file containing the response to send
filePath :: String
filePath = "./docs/Examples/BinaryResponse/circle.png"

responseHeaders :: HTTPure.Headers
responseHeaders = HTTPure.header "Content-Type" "image/png"

-- | Respond with image data when run
image :: HTTPure.Request -> HTTPure.ResponseM
image = const $ FS.readFile filePath >>= HTTPure.ok' responseHeaders

-- | Boot up the server
main :: HTTPure.ServerM
main =
  HTTPure.serve 8080 image do
    Console.log $ " ┌──────────────────────────────────────┐"
    Console.log $ " │ Server now up on port 8080           │"
    Console.log $ " │                                      │"
    Console.log $ " │ To test, run:                        │"
    Console.log $ " │  > curl -o circle.png localhost:8080 │"
    Console.log $ " └──────────────────────────────────────┘"
