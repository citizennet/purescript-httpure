module HTTPure.Request
  ( Request
  , fromHTTPRequest
  ) where

import Prelude

import Control.Monad.Aff as Aff
import Node.HTTP as HTTP

import HTTPure.Body as Body
import HTTPure.Headers as Headers
import HTTPure.HTTPureEffects as HTTPureEffects
import HTTPure.Method as Method
import HTTPure.Path as Path
import HTTPure.Query as Query

-- | The `Request` type is a `Record` type that includes fields for accessing
-- | the different parts of the HTTP request.
type Request =
  { method :: Method.Method
  , path :: Path.Path
  , query :: Query.Query
  , headers :: Headers.Headers
  , body :: Body.Body
  }

-- | Given an HTTP `Request` object, this method will convert it to an HTTPure
-- | `Request` object.
fromHTTPRequest :: forall e.
                   HTTP.Request ->
                   Aff.Aff (HTTPureEffects.HTTPureEffects e) Request
fromHTTPRequest request = do
  body <- Body.read request
  pure $
    { method: Method.read request
    , path: Path.read request
    , query: Query.read request
    , headers: Headers.read request
    , body: body
    }
