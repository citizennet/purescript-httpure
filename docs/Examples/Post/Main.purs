module Post where

import Prelude

import Control.Monad.Eff.Console as Console
import Data.StrMap as StrMap
import HTTPure as HTTPure

-- | Serve the example server on this port
port :: Int
port = 8084

-- | Shortcut for `show port`
portS :: String
portS = show port

-- | Route to the correct handler
router :: forall e. HTTPure.Request -> HTTPure.ResponseM e
router (HTTPure.Post _ _ body) = pure $ HTTPure.OK StrMap.empty body
router _                       = pure $ HTTPure.OK StrMap.empty ""

-- | Boot up the server
main :: forall e. HTTPure.ServerM (console :: Console.CONSOLE | e)
main = HTTPure.serve port router do
  Console.log $ " ┌───────────────────────────────────────────┐"
  Console.log $ " │ Server now up on port " <> portS <> "                │"
  Console.log $ " │                                           │"
  Console.log $ " │ To test, run:                             │"
  Console.log $ " │  > curl -XPOST --data test localhost:" <> portS <> " │"
  Console.log $ " │    # => test                              │"
  Console.log $ " └───────────────────────────────────────────┘"
