module Test.HTTPure.TestHelpers where

import Prelude
import Effect (Effect)
import Effect.Aff (Aff, makeAff, nonCanceler)
import Effect.Class (liftEffect)
import Effect.Ref (new, modify_, read)
import Data.Array (fromFoldable) as Array
import Data.Either (Either(Right))
import Data.List (List(Nil, Cons), reverse)
import Data.Maybe (fromMaybe)
import Data.Options ((:=))
import Data.String (toLower)
import Data.Tuple (Tuple)
import Foreign.Object (fromFoldable) as Object
import Foreign.Object (Object, lookup)
import Node.Buffer (toString) as Buffer
import Node.Buffer (Buffer, create, fromString, concat)
import Node.Encoding (Encoding(UTF8))
import Node.HTTP (Response) as HTTP
import Node.HTTP (Request)
import Node.HTTP.Client (Response, request) as HTTPClient
import Node.HTTP.Client
  ( RequestHeaders(RequestHeaders)
  , requestAsStream
  , protocol
  , method
  , hostname
  , port
  , path
  , headers
  , rejectUnauthorized
  , statusCode
  , responseHeaders
  , responseAsStream
  )
import Node.Stream (Readable, write, end, onData, onEnd)
import Test.Spec (Spec)
import Test.Spec.Assertions (shouldEqual)
import Unsafe.Coerce (unsafeCoerce)

infix 1 shouldEqual as ?=

-- | The type for integration tests.
type Test = Spec Unit

-- | The type for the entire test suite.
type TestSuite = Effect Unit

-- | Given a URL, a failure handler, and a success handler, create an HTTP
-- | client request.
request ::
  Boolean ->
  Int ->
  String ->
  Object String ->
  String ->
  Buffer ->
  Aff HTTPClient.Response
request secure port' method' headers' path' body =
  makeAff \done -> do
    req <- HTTPClient.request options $ Right >>> done
    let
      stream = requestAsStream req
    void
      $ write stream body
      $ end stream
      $ pure unit
    pure nonCanceler
  where
  options =
    protocol := (if secure then "https:" else "http:")
      <> method := method'
      <> hostname := "localhost"
      <> port := port'
      <> path := path'
      <> headers := RequestHeaders headers'
      <> rejectUnauthorized := false

-- | Same as `request` but without.
request' ::
  Boolean ->
  Int ->
  String ->
  Object String ->
  String ->
  Aff HTTPClient.Response
request' secure port method headers path =
  liftEffect (create 0)
    >>= request secure port method headers path

-- | Same as `request` but with a `String` body.
requestString ::
  Boolean ->
  Int ->
  String ->
  Object String ->
  String ->
  String ->
  Aff HTTPClient.Response
requestString secure port method headers path body = do
  liftEffect (fromString body UTF8)
    >>= request secure port method headers path

-- | Convert a request to an Aff containing the `Buffer with the response body.
toBuffer :: HTTPClient.Response -> Aff Buffer
toBuffer response =
  makeAff \done -> do
    let
      stream = responseAsStream response
    chunks <- new Nil
    onData stream $ \new -> modify_ (Cons new) chunks
    onEnd stream $ read chunks
      >>= reverse
        >>> Array.fromFoldable
        >>> concat
      >>= Right
        >>> done
    pure nonCanceler

-- | Convert a request to an Aff containing the string with the response body.
toString :: HTTPClient.Response -> Aff String
toString resp = do
  buf <- toBuffer resp
  liftEffect $ Buffer.toString UTF8 buf

-- | Run an HTTP GET with the given url and return an Aff that contains the
-- | string with the response body.
get ::
  Int ->
  Object String ->
  String ->
  Aff String
get port headers path = request' false port "GET" headers path >>= toString

-- | Like `get` but return a response body in a `Buffer`
getBinary ::
  Int ->
  Object String ->
  String ->
  Aff Buffer
getBinary port headers path = request' false port "GET" headers path >>= toBuffer

-- | Run an HTTPS GET with the given url and return an Aff that contains the
-- | string with the response body.
get' ::
  Int ->
  Object String ->
  String ->
  Aff String
get' port headers path = request' true port "GET" headers path >>= toString

-- | Run an HTTP POST with the given url and body and return an Aff that
-- | contains the string with the response body.
post ::
  Int ->
  Object String ->
  String ->
  String ->
  Aff String
post port headers path = requestString false port "POST" headers path >=> toString

-- | Run an HTTP POST with the given url and binary buffer body and return an
-- | Aff that contains the string with the response body.
postBinary ::
  Int ->
  Object String ->
  String ->
  Buffer ->
  Aff String
postBinary port headers path = request false port "POST" headers path >=> toString

-- | Convert a request to an Aff containing the string with the given header
-- | value.
extractHeader :: String -> HTTPClient.Response -> String
extractHeader header = unmaybe <<< lookup' <<< responseHeaders
  where
  unmaybe = fromMaybe ""

  lookup' = lookup $ toLower header

-- | Run an HTTP GET with the given url and return an Aff that contains the
-- | string with the header value for the given header.
getHeader ::
  Int ->
  Object String ->
  String ->
  String ->
  Aff String
getHeader port headers path header = extractHeader header <$> request' false port "GET" headers path

getStatus ::
  Int ->
  Object String ->
  String ->
  Aff Int
getStatus port headers path = statusCode <$> request' false port "GET" headers path

-- | Mock an HTTP Request object
foreign import mockRequestImpl ::
  String ->
  String ->
  String ->
  String ->
  Object String ->
  Effect Request

-- | Mock an HTTP Request object
mockRequest ::
  String ->
  String ->
  String ->
  String ->
  Array (Tuple String String) ->
  Aff Request
mockRequest httpVersion method url body = liftEffect <<< mockRequestImpl httpVersion method url body <<< Object.fromFoldable

-- | Mock an HTTP Response object
foreign import mockResponse :: Effect HTTP.Response

-- | Get the current body from an HTTP Response object (note this will only work
-- | with an object returned from mockResponse).
getResponseBody :: HTTP.Response -> String
getResponseBody = _.body <<< unsafeCoerce

-- | Get the currently set status from an HTTP Response object.
getResponseStatus :: HTTP.Response -> Int
getResponseStatus = _.statusCode <<< unsafeCoerce

-- | Get all current headers on the HTTP Response object.
getResponseHeaders :: HTTP.Response -> Object String
getResponseHeaders = unsafeCoerce <<< _.headers <<< unsafeCoerce

-- | Get the current value for the header on the HTTP Response object.
getResponseHeader :: String -> HTTP.Response -> String
getResponseHeader header = fromMaybe "" <<< lookup header <<< getResponseHeaders

-- | Create a stream out of a string.
foreign import stringToStream :: String -> Readable ()
