module Examples.Headers.Main where

import Prelude

import Effect.Console as Console
import HTTPure as HTTPure
import HTTPure ((!@))

-- | The headers that will be included in every response.
responseHeaders :: HTTPure.Headers
responseHeaders = HTTPure.header "X-Example" "hello world!"

-- | Route to the correct handler
router :: HTTPure.Request -> HTTPure.ResponseM
router { headers } = HTTPure.ok' responseHeaders $ headers !@ "X-Input"

-- | Boot up the server
main :: HTTPure.ServerM
main = HTTPure.serve 8080 router do
  Console.log $ " ┌──────────────────────────────────────────────┐"
  Console.log $ " │ Server now up on port 8080                   │"
  Console.log $ " │                                              │"
  Console.log $ " │ To test, run:                                │"
  Console.log $ " │  > curl -H 'X-Input: test' -v localhost:8080 │"
  Console.log $ " │    # => ...                                  │"
  Console.log $ " │    # => ...< X-Example: hello world!         │"
  Console.log $ " │    # => ...                                  │"
  Console.log $ " │    # => test                                 │"
  Console.log $ " └──────────────────────────────────────────────┘"
