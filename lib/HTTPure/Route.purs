module HTTPure.Route
  ( Method(..)
  , Route
  , RouteHandler
  ) where

import HTTPure.Request (Request)
import HTTPure.Response (Response)
import HTTPure.HTTPureM (HTTPureM)

-- | The available HTTP methods that a Route can service.
data Method = All | Get | Post | Put | Delete

-- | All route handler methods - that is, methods for before hooks, after hooks,
-- | or route handlers themselves - have this type signature.
type RouteHandler e = Request e -> Response e -> HTTPureM e

-- | A Route matches a given HTTP Method against a given URL string. The route
-- | string's format is inspired by express. When a request comes in that
-- | matches the route, the handler is executed against the request and the
-- | response.
type Route e = {
  method :: Method,
  route :: String,
  handler :: RouteHandler e
}

-- The internal representation of a route. The route is converted from a String
-- to a RouteMatcher, which can cheaply match routes and extract params.
--type LoadedRoute e = {
--  method :: Method,
--  route :: RouteMatcher,
--  handler :: Request e -> Response e -> HTTPure e
--}

-- The main request handler.

-- Convert the passed in routes to their internal representation.
--loadRoutes :: forall e.
--  Array (Route e) ->
--  Array (LoadedRoute e)
--loadRoutes = map \route -> {
--  method: route.method,
--  handler: route.handler,
--  route: toRouteMatcher(route.route)
--}
