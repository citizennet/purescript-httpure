module HTTPure.HTTPureM
  ( HTTPureM
  ) where

import Prelude (Unit)

import Control.Monad.Eff as Eff
import Node.HTTP as HTTP

-- | The `HTTPureM` monad represents effects run by an HTTPure server. It takes
-- | an effects row parameter which enumerates all other side-effects performed
-- | while carrying out the server actions.
type HTTPureM e t = Eff.Eff (http :: HTTP.HTTP | e) t
