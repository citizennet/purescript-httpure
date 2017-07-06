module HTTPure.HTTPureM
  ( HTTPureEffects
  , HTTPureM
  ) where

import Prelude (Unit)

import Control.Monad.Eff as Eff
import Node.HTTP as HTTP

-- | The `HTTPureMEffects` type is a row that wraps up all HTTPure effects.
-- | Under the hood this uses Node.HTTP, but it could be replaced by another
-- | adapter.
type HTTPureEffects e = (http :: HTTP.HTTP | e)

-- | The `HTTPureM` monad represents actions acting over an HTTPure server
-- | lifecycle. It is the return type of all route handlers and of the `serve`
-- | function. It takes an effects row parameter which enumerates all other
-- | side-effects performed while carrying out the server actions.
type HTTPureM e = Eff.Eff (HTTPureEffects e) Unit
