module HTTPure.HTTPureM
  ( HTTPureM
  , HTTPureEffects
  ) where

import Control.Monad.Eff as Eff
import Control.Monad.Eff.Exception as Exception
import Control.Monad.ST as ST
import Node.FS as FS
import Node.HTTP as HTTP

-- | A row of types that are used by an HTTPure server.
type HTTPureEffects e =
  ( http :: HTTP.HTTP
  , st :: ST.ST String
  , exception :: Exception.EXCEPTION
  , fs :: FS.FS
  | e
  )

-- | The `HTTPureM` monad represents effects run by an HTTPure server. It takes
-- | an effects row parameter which enumerates all other side-effects performed
-- | while carrying out the server actions.
type HTTPureM e t = Eff.Eff (HTTPureEffects e) t
