module HTTPure.Status
  ( Status
  , write
  ) where

import Prelude (Unit)

import Node.HTTP as HTTP

import HTTPure.HTTPureM as HTTPureM

-- | The Status type enumerates all valid HTTP response status codes.
type Status = Int

-- | Write a status to a given HTTP Response.
write :: forall e. HTTP.Response -> Status -> HTTPureM.HTTPureM e Unit
write = HTTP.setStatusCode
