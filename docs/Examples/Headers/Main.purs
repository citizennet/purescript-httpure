module Headers where

import Prelude

import Control.Monad.Eff.Console as Console
import HTTPure as HTTPure
import HTTPure ((!!))

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
router :: forall e. HTTPure.Request -> HTTPure.ResponseM e
router { headers } = HTTPure.ok' responseHeaders $ headers !! "X-Input"

-- | Boot up the server
main :: forall e. HTTPure.ServerM (console :: Console.CONSOLE | e)
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
