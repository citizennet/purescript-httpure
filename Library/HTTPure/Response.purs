module HTTPure.Response
  ( ResponseM
  , Response(..)
  , send
  ) where

import Prelude (Unit, discard, ($))

import Data.Maybe as Maybe
import Node.HTTP as HTTP

import HTTPure.Body as Body
import HTTPure.Headers as Headers
import HTTPure.HTTPureM as HTTPureM
import HTTPure.Status as Status

-- | A response is a status, and can have headers and a body. Different response
-- | codes will allow different response components to be sent.
data Response
  = OK Headers.Headers Body.Body

-- | The ResponseM type simply conveniently wraps up an HTTPure monad that
-- | returns a response. This type is the return type of all router/route
-- | methods.
type ResponseM e = HTTPureM.HTTPureM e Response

-- | Send a status, headers, and body to a HTTP response.
send' :: forall e.
         HTTP.Response ->
         Status.Status ->
         Headers.Headers ->
         Maybe.Maybe Body.Body ->
         HTTPureM.HTTPureM e Unit
send' response status headers body = do
  Status.write response status
  Headers.write response headers
  Body.write response $ Maybe.fromMaybe "" body

-- | Given an HTTP response and a HTTPure response, this method will return a
-- | monad encapsulating writing the HTTPure response to the HTTP response and
-- | closing the HTTP response.
send :: forall e. HTTP.Response -> Response -> HTTPureM.HTTPureM e Unit
send response (OK headers body) = send' response 200 headers (Maybe.Just body)
