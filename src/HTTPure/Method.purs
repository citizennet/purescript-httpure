module HTTPure.Method
  ( Method(..)
  , read
  ) where

import Prelude
import Node.HTTP (Request, requestMethod)

-- | These are the HTTP methods that HTTPure understands.
data Method
  = Get
  | Post
  | Put
  | Delete
  | Head
  | Connect
  | Options
  | Trace
  | Patch

-- | If two `Methods` are the same constructor, they are equal.
derive instance eqMethod :: Eq Method

-- | Convert a constructor to a `String`.
instance showMethod :: Show Method where
  show Get = "Get"
  show Post = "Post"
  show Put = "Put"
  show Delete = "Delete"
  show Head = "Head"
  show Connect = "Connect"
  show Options = "Options"
  show Trace = "Trace"
  show Patch = "Patch"

-- | Take an HTTP `Request` and extract the `Method` for that request.
read :: Request -> Method
read = requestMethod >>> case _ of
  "POST" -> Post
  "PUT" -> Put
  "DELETE" -> Delete
  "HEAD" -> Head
  "CONNECT" -> Connect
  "OPTIONS" -> Options
  "TRACE" -> Trace
  "PATCH" -> Patch
  _ -> Get
