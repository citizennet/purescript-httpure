module HelloWorld where

import Prelude (discard, pure, show, (<>), ($))

import Control.Monad.Eff.Console as Console
import Data.StrMap as StrMap
import HTTPure as HTTPure

-- | Serve the example server on this port
port :: Int
port = 8080

-- | Shortcut for `show port`
portS :: String
portS = show port

-- | Say 'hello world!' when run
sayHello :: forall e. HTTPure.Request -> HTTPure.ResponseM e
sayHello _ = pure $ HTTPure.OK StrMap.empty "hello world!"

-- | Boot up the server
main :: forall e. HTTPure.ServerM (console :: Console.CONSOLE | e)
main = HTTPure.serve port sayHello do
  Console.log $ " ┌────────────────────────────────────────────┐"
  Console.log $ " │ Server now up on port " <> portS <> "                 │"
  Console.log $ " │                                            │"
  Console.log $ " │ To test, run:                              │"
  Console.log $ " │  > curl localhost:" <> portS <> "   # => hello world! │"
  Console.log $ " └────────────────────────────────────────────┘"
