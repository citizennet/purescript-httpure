module HTTPure.HTTPureM
  ( HTTPureM
  ) where

import Control.Monad.Eff (Eff)
import Prelude (Unit)
import Node.HTTP (HTTP)

-- | The `HTTPureM` monad represents actions acting over an HTTPure server
-- | lifecycle. It is the return type of all route handlers and of the `serve`
-- | function. It takes an effects row parameter which enumerates all other
-- | side-effects performed while carrying out the server actions.
type HTTPureM e = Eff (http :: HTTP | e) Unit
