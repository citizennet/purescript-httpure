module HTTPure.Request
  ( Request(..)
  , fromHTTPRequest
  ) where

import Prelude

import Control.Monad.Aff as Aff
import Data.Show as Show
import Node.HTTP as HTTP

import HTTPure.Body as Body
import HTTPure.Headers as Headers
import HTTPure.HTTPureM as HTTPureM
import HTTPure.Path as Path

-- | A Request is a method along with headers, a path, and sometimes a body.
data Request
  = Get     Headers.Headers Path.Path
  | Post    Headers.Headers Path.Path Body.Body
  | Put     Headers.Headers Path.Path Body.Body
  | Delete  Headers.Headers Path.Path
  | Head    Headers.Headers Path.Path
  | Connect Headers.Headers Path.Path Body.Body
  | Options Headers.Headers Path.Path
  | Trace   Headers.Headers Path.Path
  | Patch   Headers.Headers Path.Path Body.Body

-- | When using show on a Request, print the method and the path.
instance show :: Show.Show Request where
  show (Get     _ path)   = "GET: "     <> path
  show (Post    _ path _) = "POST: "    <> path
  show (Put     _ path _) = "PUT: "     <> path
  show (Delete  _ path)   = "DELETE: "  <> path
  show (Head    _ path)   = "HEAD: "    <> path
  show (Connect _ path _) = "CONNECT: " <> path
  show (Options _ path)   = "OPTIONS: " <> path
  show (Trace   _ path)   = "TRACE: "   <> path
  show (Patch   _ path _) = "PATCH: "   <> path

-- | Given an HTTP Request object, this method will convert it to an HTTPure
-- | Request object.
fromHTTPRequest :: forall e.
                   HTTP.Request ->
                   Aff.Aff (HTTPureM.HTTPureEffects e) Request
fromHTTPRequest request = do
  body <- Body.read request
  pure $ case method of
    "POST"    -> Post    headers path body
    "PUT"     -> Put     headers path body
    "DELETE"  -> Delete  headers path
    "HEAD"    -> Head    headers path
    "CONNECT" -> Connect headers path body
    "OPTIONS" -> Options headers path
    "TRACE"   -> Trace   headers path
    "PATCH"   -> Patch   headers path body
    _         -> Get     headers path
  where
    method  = HTTP.requestMethod request
    headers = HTTP.requestHeaders request
    path    = HTTP.requestURL request
