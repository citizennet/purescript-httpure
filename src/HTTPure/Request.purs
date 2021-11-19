module HTTPure.Request
  ( Request
  , fromHTTPRequest
  , fullPath
  ) where

import Prelude
import Effect.Aff (Aff)
import Data.String (joinWith)
import Foreign.Object (isEmpty, toArrayWithKey)
import Node.HTTP (requestURL)
import Node.HTTP (Request) as HTTP
import Node.Stream (Readable)
import HTTPure.Body (read) as Body
import HTTPure.Headers (Headers)
import HTTPure.Headers (read) as Headers
import HTTPure.Method (Method)
import HTTPure.Method (read) as Method
import HTTPure.Path (Path)
import HTTPure.Path (read) as Path
import HTTPure.Query (Query)
import HTTPure.Query (read) as Query
import HTTPure.Utils (encodeURIComponent)
import HTTPure.Version (Version)
import HTTPure.Version (read) as Version

-- | The `Request` type is a `Record` type that includes fields for accessing
-- | the different parts of the HTTP request.
type Request =
  { method :: Method
  , path :: Path
  , query :: Query
  , headers :: Headers
  , body :: Readable ()
  , httpVersion :: Version
  , url :: String
  }

-- | Return the full resolved path, including query parameters. This may not
-- | match the requested path--for instance, if there are empty path segments in
-- | the request--but it is equivalent.
fullPath :: Request -> String
fullPath request = "/" <> path <> questionMark <> queryParams
  where
  path = joinWith "/" request.path
  questionMark = if isEmpty request.query then "" else "?"
  queryParams = joinWith "&" queryParamsArr
  queryParamsArr = toArrayWithKey stringifyQueryParam request.query
  stringifyQueryParam key value = encodeURIComponent key <> "=" <> encodeURIComponent value

-- | Given an HTTP `Request` object, this method will convert it to an HTTPure
-- | `Request` object.
fromHTTPRequest :: HTTP.Request -> Aff Request
fromHTTPRequest request = pure
  { method: Method.read request
  , path: Path.read request
  , query: Query.read request
  , headers: Headers.read request
  , body: Body.read request
  , httpVersion: Version.read request
  , url: requestURL request
  }
