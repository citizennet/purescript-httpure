module HTTPure.Request
  ( Request
  , fromHTTPRequest
  , fullPath
  ) where

import Prelude
import Data.String (joinWith)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Foreign.Object (isEmpty, toArrayWithKey)
import HTTPure.Body (RequestBody)
import HTTPure.Body (read) as Body
import HTTPure.RequestHeaders (RequestHeaders)
import HTTPure.RequestHeaders (read) as Headers
import HTTPure.Method (Method)
import HTTPure.Method (read) as Method
import HTTPure.Path (Path)
import HTTPure.Path (read) as Path
import HTTPure.Query (Query)
import HTTPure.Query (read) as Query
import HTTPure.Utils (encodeURIComponent)
import HTTPure.Version (Version)
import HTTPure.Version (read) as Version
import Node.HTTP (Request) as HTTP
import Node.HTTP (requestURL)

-- | The `Request` type is a `Record` type that includes fields for accessing
-- | the different parts of the HTTP request.
type Request =
  { method :: Method
  , path :: Path
  , query :: Query
  , headers :: RequestHeaders
  , body :: RequestBody
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
fromHTTPRequest request = do
  body <- liftEffect $ Body.read request
  pure
    { method: Method.read request
    , path: Path.read request
    , query: Query.read request
    , headers: Headers.read request
    , body
    , httpVersion: Version.read request
    , url: requestURL request
    }

