module SSL where

import Prelude

import Control.Monad.Eff.Console as Console
import HTTPure as HTTPure

-- | Serve the example server on this port
port :: Int
port = 8085

-- | Shortcut for `show port`
portS :: String
portS = show port

-- | The path to the certificate file
cert :: String
cert = "./docs/Examples/SSL/Certificate.cer"

-- | The path to the key file
key :: String
key = "./docs/Examples/SSL/Key.key"

-- | Say 'hello world!' when run
sayHello :: forall e. HTTPure.Request -> HTTPure.ResponseM e
sayHello _ = HTTPure.ok "hello world!"

-- | Boot up the server
main :: forall e. HTTPure.SecureServerM (console :: Console.CONSOLE | e)
main = HTTPure.serve' port cert key sayHello do
  Console.log $ " ┌───────────────────────────────────────────┐"
  Console.log $ " │ Server now up on port " <> portS <> "                │"
  Console.log $ " │                                           │"
  Console.log $ " │ To test, run:                             │"
  Console.log $ " │  > curl --insecure https://localhost:" <> portS <> " │"
  Console.log $ " │    # => hello world!                      │"
  Console.log $ " └───────────────────────────────────────────┘"
