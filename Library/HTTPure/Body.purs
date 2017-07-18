module HTTPure.Body
  ( Body
  , read
  , write
  ) where

import Prelude (Unit, bind, discard, pure, unit, (>>=), (<>), ($))

import Control.Monad.Aff as Aff
import Control.Monad.Eff as Eff
import Control.Monad.ST as ST
import Node.Encoding as Encoding
import Node.HTTP as HTTP
import Node.Stream as Stream

import HTTPure.HTTPureM as HTTPureM

-- | The Body type is just sugar for a String, that will be sent or received in
-- | the HTTP body.
type Body = String

-- | Extract the contents of the body of the HTTP Request.
read :: forall e. HTTP.Request -> Aff.Aff (HTTPureM.HTTPureEffects e) String
read request = Aff.makeAff \_ success -> do
  let stream = HTTP.requestAsStream request
  buf <- ST.newSTRef ""
  Stream.onDataString stream Encoding.UTF8 \str ->
    ST.modifySTRef buf (\old -> old <> str) >>= (\_ -> pure unit)
  Stream.onEnd stream $ ST.readSTRef buf >>= success

-- | Write a body to the given HTTP Response and close it.
write :: forall e. HTTP.Response -> Body -> Eff.Eff (http :: HTTP.HTTP | e) Unit
write response body = do
  _ <- Stream.writeString stream Encoding.UTF8 body noop
  Stream.end stream noop
  noop
  where
    stream = HTTP.responseAsStream response
    noop = pure unit
