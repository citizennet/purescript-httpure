module HTTPure.Request
  ( Request
  , fromHTTPRequest
  ) where

import Prelude

import Control.Monad.Aff as Aff
import Node.HTTP as HTTP

import HTTPure.Body as Body
import HTTPure.Headers as Headers
import HTTPure.HTTPureM as HTTPureM
import HTTPure.Method as Method
import HTTPure.Path as Path
import HTTPure.Query as Query

-- | A Route is a function that takes a Method, a Path, a Query, a Header, and a
-- | Body, and returns a Response monad.
type Request =
  { method :: Method.Method
  , path :: Path.Path
  , query :: Query.Query
  , headers :: Headers.Headers
  , body :: Body.Body
  }

-- | Given an HTTP Request object, this method will convert it to an HTTPure
-- | Request object.
fromHTTPRequest :: forall e.
                   HTTP.Request ->
                   Aff.Aff (HTTPureM.HTTPureEffects e) Request
fromHTTPRequest request = do
  body <- Body.read request
  pure $
    { method: Method.read request
    , path: Path.read request
    , query: Query.read request
    , headers: Headers.read request
    , body: body
    }
