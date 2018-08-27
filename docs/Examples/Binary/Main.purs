module Examples.Binary.Main where

import Prelude

import Effect.Console as Console
import Node.FS.Aff as FS
import HTTPure as HTTPure

-- | Serve the example server on this port
port :: Int
port = 8090

-- | Shortcut for `show port`
portS :: String
portS = show port

-- | The path to the file containing the response to send
filePath :: String
filePath = "./docs/Examples/Binary/circle.png"

-- | Respond with image data when run
image :: HTTPure.Request -> HTTPure.ResponseM
image _ = FS.readFile filePath >>= HTTPure.ok' headers
  where
    headers = HTTPure.header "Content-Type" "image/png"

-- | Boot up the server
main :: HTTPure.ServerM
main = HTTPure.serve port image do
  Console.log $ " ┌────────────────────────────────────────────┐"
  Console.log $ " │ Server now up on port " <> portS <> "                 │"
  Console.log $ " │                                            │"
  Console.log $ " │ To test, run:                              │"
  Console.log $ " │  > curl -o circle.png localhost:" <> portS <> "       │"
  Console.log $ " └────────────────────────────────────────────┘"
