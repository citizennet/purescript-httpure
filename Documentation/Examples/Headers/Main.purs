module Headers where

import Prelude (discard, flip, pure, show, (<>), ($), (<<<))

import Control.Monad.Eff.Console as Console
import Data.StrMap as StrMap
import HTTPure as HTTPure

-- | Serve the example server on this port
port :: Int
port = 8082

-- | Shortcut for `show port`
portS :: String
portS = show port

-- | Read X-Input back to the body and set the X-Example header
sayHello :: HTTPure.Headers -> HTTPure.Response
sayHello = HTTPure.OK responseHeaders <<< flip HTTPure.lookup "X-Input"
  where
    responseHeaders = StrMap.singleton "X-Example" "hello world!"

-- | Route to the correct handler
router :: forall e. HTTPure.Request -> HTTPure.ResponseM e
router (HTTPure.Get headers _) = pure $ sayHello headers
router _                       = pure $ HTTPure.OK StrMap.empty ""

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
