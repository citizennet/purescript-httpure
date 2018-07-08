module Examples.Headers.Main where

import Prelude

import Effect.Console as Console
import HTTPure as HTTPure
import HTTPure ((!@))

-- | Serve the example server on this port
port :: Int
port = 8082

-- | Shortcut for `show port`
portS :: String
portS = show port

-- | The headers that will be included in every response.
responseHeaders :: HTTPure.Headers
responseHeaders = HTTPure.header "X-Example" "hello world!"

-- | Route to the correct handler
router :: HTTPure.Request -> HTTPure.ResponseM
router { headers } = HTTPure.ok' responseHeaders $ headers !@ "X-Input"

-- | Boot up the server
main :: HTTPure.ServerM
main = HTTPure.serve port router do
  Console.log $ " ┌──────────────────────────────────────────────┐"
  Console.log $ " │ Server now up on port " <> portS <> "                   │"
  Console.log $ " │                                              │"
  Console.log $ " │ To test, run:                                │"
  Console.log $ " │  > curl -H 'X-Input: test' -v localhost:" <> portS <> " │"
  Console.log $ " │    # => ...                                  │"
  Console.log $ " │    # => ...< X-Example: hello world!         │"
  Console.log $ " │    # => ...                                  │"
  Console.log $ " │    # => test                                 │"
  Console.log $ " └──────────────────────────────────────────────┘"
