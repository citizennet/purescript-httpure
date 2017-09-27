module HTTPure.HTTPureEffects
  ( HTTPureEffects
  ) where

import Control.Monad.Eff.Exception as Exception
import Control.Monad.ST as ST
import Node.HTTP as HTTP

-- | A row of types that are used by an HTTPure server.
type HTTPureEffects e =
  ( http :: HTTP.HTTP
  , st :: ST.ST String
  , exception :: Exception.EXCEPTION
  | e
  )
