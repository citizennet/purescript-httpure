module HTTPure.Body
  ( Body
  , write
  ) where

import Prelude (Unit, bind, discard, pure, unit)

import Node.Encoding as Encoding
import Node.HTTP as HTTP
import Node.Stream as Stream

import HTTPure.HTTPureM as HTTPureM

-- | The Body type is just sugar for a String, that will be sent or received in
-- | the HTTP body.
type Body = String

-- | Write a body to the given HTTP Response and close it.
write :: forall e. HTTP.Response -> Body -> HTTPureM.HTTPureM e Unit
write response body = do
  _ <- Stream.writeString stream Encoding.UTF8 body noop
  Stream.end stream noop
  noop
  where
    stream = HTTP.responseAsStream response
    noop = pure unit
