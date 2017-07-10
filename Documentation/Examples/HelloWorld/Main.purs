module HelloWorld where

import Prelude (discard, show, (<>), ($))

import Control.Monad.Eff.Console as Console
import HTTPure as HTTPure

-- | Serve the example server on this port
port :: Int
port = 8080

-- | Shortcut for `show port`
portS :: String
portS = show port

-- | Specify the routes
routes :: forall e. Array (HTTPure.Route e)
routes =
  [ HTTPure.Get "/"
    { status: \_ -> 200
    , headers: \_ -> []
    , body: \_ -> "hello world!"
    }
  ]

-- | Boot up the server
main :: forall e. HTTPure.HTTPureM (console :: Console.CONSOLE | e)
main = HTTPure.serve port routes do
  Console.log $ ""
  Console.log $ " ┌────────────────────────────────────────────┐"
  Console.log $ " │ Server now up on port " <> portS <> "                 │"
  Console.log $ " │                                            │"
  Console.log $ " │ To test, run:                              │"
  Console.log $ " │  > curl localhost:" <> portS <> "   # => hello world! │"
  Console.log $ " └────────────────────────────────────────────┘"
