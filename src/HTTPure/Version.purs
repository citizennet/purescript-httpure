module HTTPure.Version
  ( Version(..)
  , read
  ) where

import Prelude
import Node.HTTP (Request, httpVersion)

-- | These are the HTTP versions that HTTPure understands. There are five
-- | commonly known versions which are explicitly named.
data Version
  = HTTP0_9
  | HTTP1_0
  | HTTP1_1
  | HTTP2_0
  | HTTP3_0
  | Other String

-- | If two `Versions` are the same constructor, they are equal.
derive instance eqVersion :: Eq Version

-- | Allow a `Version` to be represented as a string. This string is formatted
-- | as it would be in an HTTP request/response.
instance showVersion :: Show Version where
  show HTTP0_9 = "HTTP/0.9"
  show HTTP1_0 = "HTTP/1.0"
  show HTTP1_1 = "HTTP/1.1"
  show HTTP2_0 = "HTTP/2.0"
  show HTTP3_0 = "HTTP/3.0"
  show (Other version) = "HTTP/" <> version

-- | Take an HTTP `Request` and extract the `Version` for that request.
read :: Request -> Version
read = httpVersion >>> case _ of
  "0.9" -> HTTP0_9
  "1.0" -> HTTP1_0
  "1.1" -> HTTP1_1
  "2.0" -> HTTP2_0
  "3.0" -> HTTP3_0
  version -> Other version
