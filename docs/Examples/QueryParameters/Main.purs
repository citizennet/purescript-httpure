module Examples.QueryParameters.Main where

import Prelude

import Effect.Console as Console
import HTTPure as HTTPure
import HTTPure ((!@), (!?))

-- | Serve the example server on this port
port :: Int
port = 8087

-- | Shortcut for `show port`
portS :: String
portS = show port

-- | Specify the routes
router :: HTTPure.Request -> HTTPure.ResponseM
router { query }
  | query !? "foo"           = HTTPure.ok "foo"
  | query !@ "bar" == "test" = HTTPure.ok "bar"
  | otherwise                = HTTPure.ok $ query !@ "baz"

-- | Boot up the server
main :: HTTPure.ServerM
main = HTTPure.serve port router do
  Console.log $ " ┌────────────────────────────────────────┐"
  Console.log $ " │ Server now up on port " <> portS <> "             │"
  Console.log $ " │                                        │"
  Console.log $ " │ To test, run:                          │"
  Console.log $ " │  > curl localhost:" <> portS <> "?foo             │"
  Console.log $ " │    # => foo                            │"
  Console.log $ " │  > curl localhost:" <> portS <> "?bar=test        │"
  Console.log $ " │    # => bar                            │"
  Console.log $ " │  > curl localhost:" <> portS <> "?baz=<anything>  │"
  Console.log $ " │    # => <anything>                     │"
  Console.log $ " └────────────────────────────────────────┘"
