module HTTPure.Server (
  serve
) where

import Data.Maybe (Maybe(Nothing))
import Data.Traversable (traverse_)
import Node.HTTP (Request, Response, ListenOptions, createServer, listen) as HTTP
import Node.Stream (end)
import Prelude (bind, discard, pure, unit, ($), (==))
import Data.Array (filter)

import HTTPure.Route (Route)
import HTTPure.Response (fromHTTPResponse)
import HTTPure.Request (fromHTTPRequest, getURL)
import HTTPure.HTTPureM (HTTPureM)

-- | TODO write me
handleRequest :: forall e. Array (Route e) -> HTTP.Request -> HTTP.Response -> HTTPureM e
handleRequest routes request response = do
  traverse_ (\route -> route.handler req resp) (filter matching routes)
  end resp (pure unit)
  pure unit
  where
    req  = fromHTTPRequest request
    resp = fromHTTPResponse response
    matching = \route -> route.route == getURL req

-- | TODO write me
getOptions :: Int -> HTTP.ListenOptions
getOptions port = {
  hostname: "localhost",
  port: port,
  backlog: Nothing
}

-- | TODO write me
serve :: forall e. Array (Route e) -> Int -> HTTPureM e -> HTTPureM e
serve routes port onStarted = do
  server <- HTTP.createServer $ handleRequest routes -- $ loadRoutes routes
  HTTP.listen server (getOptions port) onStarted
