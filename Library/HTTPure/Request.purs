module HTTPure.Request
  ( Request(..)
  , fromHTTPRequest
  ) where

import Prelude ((<>))

import Data.Show as Show
import Node.HTTP as HTTP

import HTTPure.Body as Body
import HTTPure.Headers as Headers
import HTTPure.Path as Path

-- | A Request is a method along with headers, a path, and sometimes a body.
data Request
  = Get    Headers.Headers Path.Path
  | Post   Headers.Headers Path.Path Body.Body
  | Put    Headers.Headers Path.Path Body.Body
  | Delete Headers.Headers Path.Path

-- | When using show on a Request, print the method and the path.
instance show :: Show.Show Request where
  show (Get _ path) = "GET: " <> path
  show (Post _ path _) = "POST: " <> path
  show (Put _ path _) = "PUT: " <> path
  show (Delete _ path) = "DELETE: " <> path

-- | Given an HTTP Request object, this method will convert it to an HTTPure
-- | Request object.
fromHTTPRequest :: HTTP.Request -> Request
fromHTTPRequest request =
  case method of
    "POST" -> Post headers path ""
    "PUT" -> Put headers path ""
    "DELETE" -> Delete headers path
    _ -> Get headers path
  where
    method = HTTP.requestMethod request
    headers = HTTP.requestHeaders request
    path = HTTP.requestURL request
