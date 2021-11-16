module Examples.BinaryRequest.Main where

import Prelude
import Effect.Console as Console
import Node.Buffer (Buffer)
import HTTPure as HTTPure

foreign import sha256sum :: Buffer -> String

-- | Respond with file's sha256sum
router :: HTTPure.Request -> HTTPure.ResponseM
router { body } = HTTPure.toBuffer body >>= sha256sum >>> HTTPure.ok

-- | Boot up the server
main :: HTTPure.ServerM
main =
  HTTPure.serve 8080 router do
    Console.log $ " ┌─────────────────────────────────────────────────────────┐"
    Console.log $ " │ Server now up on port 8080                              │"
    Console.log $ " │                                                         │"
    Console.log $ " │ To test, run:                                           │"
    Console.log $ " │  > curl -XPOST --data-binary @circle.png localhost:8080 │"
    Console.log $ " │                          # => d5e776724dd5...           │"
    Console.log $ " └─────────────────────────────────────────────────────────┘"
