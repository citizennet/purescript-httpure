module HTTPure.Response
  ( ResponseM
  , Response(..)
  , send
  ) where

import Prelude (Unit, bind, discard, pure, unit)

import Node.Encoding as Encoding
import Node.HTTP as HTTP
import Node.Stream as Stream

import HTTPure.Body as Body
import HTTPure.Headers as Headers
import HTTPure.HTTPureM as HTTPureM

-- | A response is a status, and can have headers and a body. Different response
-- | codes will allow different response components to be sent.
data Response
  = OK Headers.Headers Body.Body

-- | The ResponseM type simply conveniently wraps up an HTTPure monad that
-- | returns a response. This type is the return type of all router/route
-- | methods.
type ResponseM e = HTTPureM.HTTPureM e Response

-- | Given an HTTP response and a HTTPure response, this method will return a
-- | monad encapsulating writing the HTTPure response to the HTTP response and
-- | closing the HTTP response.
send :: forall e. HTTP.Response -> Response -> HTTPureM.HTTPureM e Unit
send response (OK headers body) = do
  _ <- Stream.writeString stream Encoding.UTF8 body noop
  Stream.end stream noop
  noop
  where
    stream = HTTP.responseAsStream response
    noop = pure unit
