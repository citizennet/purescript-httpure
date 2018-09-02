module Examples.QueryParameters.Main where

import Prelude

import Effect.Console as Console
import HTTPure as HTTPure
import HTTPure ((!@), (!?))

-- | Specify the routes
router :: HTTPure.Request -> HTTPure.ResponseM
router { query }
  | query !? "foo"           = HTTPure.ok "foo"
  | query !@ "bar" == "test" = HTTPure.ok "bar"
  | otherwise                = HTTPure.ok $ query !@ "baz"

-- | Boot up the server
main :: HTTPure.ServerM
main = HTTPure.serve 8080 router do
  Console.log $ " ┌────────────────────────────────────────┐"
  Console.log $ " │ Server now up on port 8080             │"
  Console.log $ " │                                        │"
  Console.log $ " │ To test, run:                          │"
  Console.log $ " │  > curl localhost:8080?foo             │"
  Console.log $ " │    # => foo                            │"
  Console.log $ " │  > curl localhost:8080?bar=test        │"
  Console.log $ " │    # => bar                            │"
  Console.log $ " │  > curl localhost:8080?baz=<anything>  │"
  Console.log $ " │    # => <anything>                     │"
  Console.log $ " └────────────────────────────────────────┘"
