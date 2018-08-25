module Test.HTTPure.TestHelpers where

import Prelude

import Effect as Effect
import Effect.Aff as Aff
import Effect.Class as EffectClass
import Effect.Ref as Ref
import Data.Array as Array
import Data.Either as Either
import Data.List as List
import Data.Maybe as Maybe
import Data.Options ((:=))
import Data.String as StringUtil
import Data.Tuple as Tuple
import Foreign.Object as Object
import Node.Buffer as Buffer
import Node.Encoding as Encoding
import Node.HTTP as HTTP
import Node.HTTP.Client as HTTPClient
import Node.Stream as Stream
import Test.Spec as Spec
import Test.Spec.Assertions as Assertions
import Unsafe.Coerce as Coerce

infix 1 Assertions.shouldEqual as ?=

-- | The type for integration tests.
type Test = Spec.Spec Unit

-- | The type for the entire test suite.
type TestSuite = Effect.Effect Unit

-- | Given a URL, a failure handler, and a success handler, create an HTTP
-- | client request.
request :: Boolean ->
           Int ->
           String ->
           Object.Object String ->
           String ->
           String ->
           Aff.Aff HTTPClient.Response
request secure port method headers path body = Aff.makeAff \done -> do
  req <- HTTPClient.request options $ Either.Right >>> done
  let stream = HTTPClient.requestAsStream req
  _ <- Stream.writeString stream Encoding.UTF8 body $ pure unit
  Stream.end stream $ pure unit
  pure Aff.nonCanceler
  where
    options =
      HTTPClient.protocol := (if secure then "https:" else "http:") <>
      HTTPClient.method   := method <>
      HTTPClient.hostname := "localhost" <>
      HTTPClient.port     := port <>
      HTTPClient.path     := path <>
      HTTPClient.headers  := HTTPClient.RequestHeaders headers <>
      HTTPClient.rejectUnauthorized := false

-- | Read parts of a stream to a string.
streamToString :: Stream.Readable () -> Aff.Aff String
streamToString stream = Aff.makeAff \done -> do
  buf <- Ref.new ""
  Stream.onDataString stream Encoding.UTF8 \str ->
    void $ Ref.modify ((<>) str) buf
  Stream.onEnd stream $ Ref.read buf >>= Either.Right >>> done
  pure Aff.nonCanceler

-- | Convert a request to an Aff containing the `Buffer with the response body.
toBuffer :: HTTPClient.Response -> Aff.Aff Buffer.Buffer
toBuffer response = Aff.makeAff \done -> do
  let stream = HTTPClient.responseAsStream response
  chunks <- Ref.new List.Nil
  Stream.onData stream $ \new -> Ref.modify_ (List.Cons new) chunks
  Stream.onEnd stream $
    Ref.read chunks
    >>= List.reverse >>> Array.fromFoldable >>> Buffer.concat
    >>= Either.Right >>> done
  pure Aff.nonCanceler

-- | Convert a request to an Aff containing the string with the response body.
toString :: HTTPClient.Response -> Aff.Aff String
toString resp = do
  buf <- toBuffer resp
  EffectClass.liftEffect $ Buffer.toString Encoding.UTF8 buf

-- | Run an HTTP GET with the given url and return an Aff that contains the
-- | string with the response body.
get :: Int ->
       Object.Object String ->
       String ->
       Aff.Aff String
get port headers path = request false port "GET" headers path "" >>= toString

-- | Like `get` but return a response body in a `Buffer`
getBinary :: Int ->
             Object.Object String ->
             String ->
             Aff.Aff Buffer.Buffer
getBinary port headers path =
  request false port "GET" headers path "" >>= toBuffer

-- | Run an HTTPS GET with the given url and return an Aff that contains the
-- | string with the response body.
get' :: Int ->
        Object.Object String ->
        String ->
        Aff.Aff String
get' port headers path = request true port "GET" headers path "" >>= toString

-- | Run an HTTP POST with the given url and body and return an Aff that
-- | contains the string with the response body.
post :: Int ->
        Object.Object String ->
        String ->
        String ->
        Aff.Aff String
post port headers path = request false port "POST" headers path >=> toString

-- | Convert a request to an Aff containing the string with the given header
-- | value.
extractHeader :: String -> HTTPClient.Response -> String
extractHeader header = unmaybe <<< lookup <<< HTTPClient.responseHeaders
  where
    unmaybe = Maybe.fromMaybe ""
    lookup = Object.lookup $ StringUtil.toLower header

-- | Run an HTTP GET with the given url and return an Aff that contains the
-- | string with the header value for the given header.
getHeader :: Int ->
             Object.Object String ->
             String ->
             String ->
             Aff.Aff String
getHeader port headers path header =
  extractHeader header <$> request false port "GET" headers path ""

-- | Mock an HTTP Request object
foreign import mockRequestImpl ::
  String ->
  String ->
  String ->
  Object.Object String ->
  Effect.Effect HTTP.Request

-- | Mock an HTTP Request object
mockRequest :: String ->
               String ->
               String ->
               Array (Tuple.Tuple String String) ->
               Aff.Aff HTTP.Request
mockRequest method url body =
  EffectClass.liftEffect <<< mockRequestImpl method url body <<< Object.fromFoldable

-- | Mock an HTTP Response object
foreign import mockResponse ::
  Effect.Effect HTTP.Response

-- | Get the current body from an HTTP Response object (note this will only work
-- | with an object returned from mockResponse).
getResponseBody :: HTTP.Response -> String
getResponseBody = _.body <<< Coerce.unsafeCoerce

-- | Get the currently set status from an HTTP Response object.
getResponseStatus :: HTTP.Response -> Int
getResponseStatus = _.statusCode <<< Coerce.unsafeCoerce

-- | Get all current headers on the HTTP Response object.
getResponseHeaders :: HTTP.Response -> Object.Object String
getResponseHeaders = Coerce.unsafeCoerce <<< _.headers <<< Coerce.unsafeCoerce

-- | Get the current value for the header on the HTTP Response object.
getResponseHeader :: String -> HTTP.Response -> String
getResponseHeader header =
  Maybe.fromMaybe "" <<< Object.lookup header <<< getResponseHeaders
