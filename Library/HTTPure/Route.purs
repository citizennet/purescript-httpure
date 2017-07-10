module HTTPure.Route
  ( Route(..)
  , RouteHooks
  , run
  , match
  , isMatch
  ) where

import Prelude (flip, ($), (==), (>>=), (<>))

import Data.Array as Array
import Data.Eq as Eq
import Data.Maybe as Maybe
import Data.Show as Show

import HTTPure.HTTPureM as HTTPureM
import HTTPure.Request as Request
import HTTPure.Response as Response

type RouteHooks e =
  { status :: Request.Request e -> Int
  , body :: Request.Request e -> String
  , headers :: Request.Request e -> Array String
  }

-- | A Route matches a given HTTP Method against a given path matcher string.
-- | When a request comes in that matches the route, the body function is
-- | executed against the request and the result is sent back to the client.
data Route e
  = Get String (RouteHooks e)
  | Post String (RouteHooks e)
  | Put String (RouteHooks e)
  | Delete String (RouteHooks e)

-- | When calling `show` on a route, display the method and the matching
-- | pattern.
instance show :: Show.Show (Route e) where
  show (Get pattern _) = "GET: " <> pattern
  show (Post pattern _) = "POST: " <> pattern
  show (Put pattern _) = "PUT: " <> pattern
  show (Delete pattern _) = "DELETE: " <> pattern

-- | Two routes are equal if they are the same method and have the same matching
-- | pattern.
instance eq :: Eq.Eq (Route e) where
  eq (Get pattern1 _) (Get pattern2 _) = pattern1 == pattern2
  eq (Post pattern1 _) (Post pattern2 _) = pattern1 == pattern2
  eq (Put pattern1 _) (Put pattern2 _) = pattern1 == pattern2
  eq (Delete pattern1 _) (Delete pattern2 _) = pattern1 == pattern2
  eq _ _ = false

-- | Given a route and a request, return the response body.
run :: forall e.
       Route e ->
       Request.Request e ->
       Response.Response e ->
       HTTPureM.HTTPureM e
run (Get _ { body: body }) req resp = Response.write resp $ body req
run (Post _ { body: body }) req resp = Response.write resp $ body req
run (Put _ { body: body }) req resp = Response.write resp $ body req
run (Delete _ { body: body }) req resp = Response.write resp $ body req

-- | Returns true if the request matches the route.
isMatch :: forall e. Route e -> Request.Request e -> Boolean
isMatch (Get matcher _) request = matcher == Request.getURL request
isMatch (Post matcher _) request = matcher == Request.getURL request
isMatch (Put matcher _) request = matcher == Request.getURL request
isMatch (Delete matcher _) request = matcher == Request.getURL request

-- | Returns the matching route for the request.
match :: forall e. Array (Route e) -> Request.Request e -> Maybe.Maybe (Route e)
match routes request =
  Array.findIndex (flip isMatch request) routes >>= Array.index routes
