module HTTPure.Request
  ( Request
  , fromHTTPRequest
  , getURL
  ) where

import Node.HTTP (HTTP, Request, requestAsStream, requestURL) as HTTP
import Node.Stream (Readable)

-- | TODO write me
type Request e = {
  httpRequest :: HTTP.Request,
  stream :: Readable () (http :: HTTP.HTTP | e)
}

-- | TODO write me
fromHTTPRequest :: forall e. HTTP.Request -> Request e
fromHTTPRequest request = {
  httpRequest: request,
  stream: HTTP.requestAsStream request
}

-- | TODO write me
getURL :: forall e. Request e -> String
getURL request = HTTP.requestURL request.httpRequest
