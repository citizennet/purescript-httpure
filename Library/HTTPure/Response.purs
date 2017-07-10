module HTTPure.Response
  ( Response
  , fromHTTPResponse
  , write
  ) where

import Prelude (Unit, bind, discard, pure, unit)

import Control.Monad.Eff as Eff
import Node.Encoding as Encoding
import Node.HTTP as HTTP
import Node.Stream as Stream

-- | The Response type takes as it's parameter an effects row. It is a Record
-- | type with two fields:
-- |
-- | - `httpResponse`: The raw underlying HTTP response.
-- | - `stream`: The raw response converted to a Writable stream.
-- |
-- | Neither field is intended to be accessed directly, rather it is recommended
-- | to use the methods exported by this module.
type Response e =
  { httpResponse :: HTTP.Response
  , stream :: Stream.Writable () (http :: HTTP.HTTP | e)
  }

-- | Convert a Node.HTTP Response into a HTTPure Response.
fromHTTPResponse :: forall e. HTTP.Response -> Response e
fromHTTPResponse response =
  { httpResponse: response
  , stream: HTTP.responseAsStream response
  }

-- | Write a string into the Response output.
write :: forall e. Response e -> String -> Eff.Eff (http :: HTTP.HTTP | e) Unit
write response str = do
  _ <- Stream.writeString response.stream Encoding.UTF8 str noop
  Stream.end response.stream noop
  noop
  where
    noop = pure unit
