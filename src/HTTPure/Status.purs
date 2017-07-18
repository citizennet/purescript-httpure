module HTTPure.Status
  ( Status
  , write
  ) where

import Prelude

import Control.Monad.Eff as Eff
import Node.HTTP as HTTP

-- | The Status type enumerates all valid HTTP response status codes.
type Status = Int

-- | Write a status to a given HTTP Response.
write :: forall e.
         HTTP.Response ->
         Status ->
         Eff.Eff (http :: HTTP.HTTP | e) Unit
write = HTTP.setStatusCode
