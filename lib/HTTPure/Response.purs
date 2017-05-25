module HTTPure.Response
  ( Response
  , fromHTTPResponse
  , write
  ) where

import Control.Monad.Eff (Eff)
import Node.Encoding (Encoding(UTF8))
import Node.HTTP (HTTP, Response, responseAsStream) as HTTP
import Node.Stream (Writable, writeString)
import Prelude (Unit, bind, pure, unit)

-- | TODO write me
-- | TODO wrap me in a Record so that the HTTP response is accessible
type Response e = Writable () (http :: HTTP.HTTP | e)

-- | TODO write me
fromHTTPResponse :: forall e. HTTP.Response -> Response e
fromHTTPResponse = HTTP.responseAsStream

-- | TODO write me
--setStatusCode ::

-- | TODO write me
write :: forall e. Response e -> String -> Eff (http :: HTTP.HTTP | e) Unit
write response str = do
  _ <- writeString response UTF8 str (pure unit)
  pure unit
