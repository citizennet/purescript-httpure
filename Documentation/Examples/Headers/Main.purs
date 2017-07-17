module Headers where

import Prelude (discard, pure, show, (<>), ($))

import Control.Monad.Eff.Console as Console
import Data.StrMap as StrMap
import HTTPure as HTTPure

-- | Serve the example server on this port
port :: Int
port = 8082

-- | Shortcut for `show port`
portS :: String
portS = show port

-- | Say 'hello world!' when run
sayHello :: forall e. HTTPure.Request -> HTTPure.ResponseM e
sayHello _ = pure $ HTTPure.OK (StrMap.singleton "X-Example" "hello world!") ""

-- | Boot up the server
main :: forall e. HTTPure.ServerM (console :: Console.CONSOLE | e)
main = HTTPure.serve port sayHello do
  Console.log $ " ┌──────────────────────────────────────────────────────────────┐"
  Console.log $ " │ Server now up on port " <> portS <> "                                   │"
  Console.log $ " │                                                              │"
  Console.log $ " │ To test, run:                                                │"
  Console.log $ " │  > curl -v localhost:" <> portS <> "   # => ... X-Example: hello world! │"
  Console.log $ " └──────────────────────────────────────────────────────────────┘"
