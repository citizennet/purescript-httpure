module HTTPure.Request
  ( Request
  , fromHTTPRequest
  , fullPath
  ) where

import Prelude
import Effect.Aff as Aff
import Data.String as String
import Foreign.Object as Object
import Node.HTTP as HTTP
import HTTPure.Body as Body
import HTTPure.Headers as Headers
import HTTPure.Method as Method
import HTTPure.Path as Path
import HTTPure.Query as Query
import HTTPure.Utils (encodeURIComponent)
import HTTPure.Version as Version

-- | The `Request` type is a `Record` type that includes fields for accessing
-- | the different parts of the HTTP request.
type Request
  = { method :: Method.Method
    , path :: Path.Path
    , query :: Query.Query
    , headers :: Headers.Headers
    , body :: String
    , httpVersion :: Version.Version
    , url :: String
    }

-- | Return the full resolved path, including query parameters. This may not
-- | match the requested path--for instance, if there are empty path segments in
-- | the request--but it is equivalent.
fullPath :: Request -> String
fullPath request = "/" <> path <> questionMark <> queryParams
  where
  path = String.joinWith "/" request.path

  questionMark = if Object.isEmpty request.query then "" else "?"

  queryParams = String.joinWith "&" queryParamsArr

  queryParamsArr = Object.toArrayWithKey stringifyQueryParam request.query

  stringifyQueryParam key value = encodeURIComponent key <> "=" <> encodeURIComponent value

-- | Given an HTTP `Request` object, this method will convert it to an HTTPure
-- | `Request` object.
fromHTTPRequest :: HTTP.Request -> Aff.Aff Request
fromHTTPRequest request = do
  body <- Body.read request
  pure
    $ { method: Method.read request
      , path: Path.read request
      , query: Query.read request
      , headers: Headers.read request
      , body
      , httpVersion: Version.read request
      , url: HTTP.requestURL request
      }
