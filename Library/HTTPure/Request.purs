module HTTPure.Request
  ( Request
  , fromHTTPRequest
  , getURL
  ) where

import Node.HTTP as HTTP
import Node.Stream as Stream

-- | The Request type takes as it's parameter an effects row. It is a Record
-- | type with two fields:
-- |
-- | - `httpRequest`: The raw underlying HTTP request.
-- | - `stream`: The raw request converted to a Readable stream.
-- |
-- | Neither field is intended to be accessed directly, rather it is recommended
-- | to use the methods exported by this module.
type Request e =
  { httpRequest :: HTTP.Request
  , stream :: Stream.Readable () (http :: HTTP.HTTP | e)
  }

-- | Convert a Node.HTTP Request into a HTTPure Request.
fromHTTPRequest :: forall e. HTTP.Request -> Request e
fromHTTPRequest request =
  { httpRequest: request
  , stream: HTTP.requestAsStream request
  }

-- | Get the URL used to generate a Request.
getURL :: forall e. Request e -> String
getURL request = HTTP.requestURL request.httpRequest
