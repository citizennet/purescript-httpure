module HTTPure.Request
  ( Request
  , fromHTTPRequest
  , fullPath
  , readBodyAsBuffer
  , readBodyAsStream
  , readBodyAsString
  ) where

import Prelude
import Data.Maybe (Maybe(..))
import Data.String (joinWith)
import Effect.Aff (Aff)
import Effect.Class (liftEffect)
import Effect.Ref (Ref)
import Effect.Ref (read, modify_, new) as Ref
import Foreign.Object (isEmpty, toArrayWithKey)
import HTTPure.Body (RequestBody)
import HTTPure.Body (read, toBuffer) as Body
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
import Node.Buffer (Buffer)
import Node.Buffer as Buffer
import Node.Encoding (Encoding(..))
import Node.HTTP (Request) as HTTP
import Node.HTTP (requestURL)
import Node.Stream (Readable)

-- | The `Request` type is a `Record` type that includes fields for accessing
-- | the different parts of the HTTP request.
type Request =
  { method :: Method
  , path :: Path
  , query :: Query
  , headers :: Headers
  , body :: Ref RequestBody
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
  body <-
    liftEffect
      $ Ref.new
          { buffer: Nothing
          , stream: Body.read request
          , string: Nothing
          }
  pure
    { method: Method.read request
    , path: Path.read request
    , query: Query.read request
    , headers: Headers.read request
    , body
    , httpVersion: Version.read request
    , url: requestURL request
    }

readBodyAsBuffer :: Request -> Aff Buffer
readBodyAsBuffer request = do
  body <-
    liftEffect
      $ Ref.read request.body
  case body.buffer of
    Nothing -> do
      buffer <- Body.toBuffer body.stream
      liftEffect
        $ Ref.modify_ (_ { buffer = Just buffer }) request.body
      pure buffer
    Just buffer -> pure buffer

readBodyAsStream :: Request -> Aff (Readable ())
readBodyAsStream request = do
  body <-
    liftEffect
      $ Ref.read request.body
  pure body.stream

readBodyAsString :: Request -> Aff String
readBodyAsString request = do
  body <-
    liftEffect
      $ Ref.read request.body
  case body.string of
    Nothing -> do
      buffer <- readBodyAsBuffer request
      string <- liftEffect
        $ Buffer.toString UTF8 buffer
      liftEffect
        $ Ref.modify_ (_ { string = Just string }) request.body
      pure string
    Just string -> pure string

