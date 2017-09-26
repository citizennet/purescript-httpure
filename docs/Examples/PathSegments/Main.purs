module PathSegments where

import Prelude

import Control.Monad.Eff.Console as Console
import HTTPure as HTTPure
import HTTPure ((!!))

-- | Serve the example server on this port
port :: Int
port = 8086

-- | Shortcut for `show port`
portS :: String
portS = show port

-- | Specify the routes
router :: forall e. HTTPure.Request -> HTTPure.ResponseM e
router { path }
  | path !! 0 == "segment" = HTTPure.ok $ path !! 1
  | otherwise              = HTTPure.ok $ show path

-- | Boot up the server
main :: forall e. HTTPure.ServerM (console :: Console.CONSOLE | e)
main = HTTPure.serve port router do
  Console.log $ " ┌───────────────────────────────────────────────┐"
  Console.log $ " │ Server now up on port " <> portS <> "                    │"
  Console.log $ " │                                               │"
  Console.log $ " │ To test, run:                                 │"
  Console.log $ " │  > curl localhost:" <> portS <> "/segment/<anything>     │"
  Console.log $ " │    # => <anything>                            │"
  Console.log $ " │  > curl localhost:" <> portS <> "/<anything>/<else>/...  │"
  Console.log $ " │    # => [ <anything>, <else>, ... ]           │"
  Console.log $ " └───────────────────────────────────────────────┘"
