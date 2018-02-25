module Test.HTTPure.TestHelpers where

import Prelude

import Control.Monad.Aff as Aff
import Control.Monad.Eff as Eff
import Control.Monad.Eff.Class as EffClass
import Control.Monad.Eff.Exception as Exception
import Control.Monad.ST as ST
import Data.Either as Either
import Data.Maybe as Maybe
import Data.Options ((:=))
import Data.String as StringUtil
import Data.StrMap as StrMap
import Data.Tuple as Tuple
import Node.Encoding as Encoding
import Node.FS as FS
import Node.HTTP as HTTP
import Node.HTTP.Client as HTTPClient
import Node.Stream as Stream
import Test.Spec as Spec
import Test.Spec.Runner as Runner
import Test.Spec.Assertions as Assertions
import Unsafe.Coerce as Coerce

infix 1 Assertions.shouldEqual as ?=

-- | A type alias encapsulating all effect types used in making a mock request.
type HTTPRequestEffects e =
  ( st :: ST.ST String
  , exception :: Exception.EXCEPTION
  , http :: HTTP.HTTP
  | e
  )

-- | A type alias encapsulating all effect types used in tests.
type TestEffects =
  Runner.RunnerEffects (
    HTTPRequestEffects
      ( mockResponse :: MOCK_RESPONSE
      , mockRequest :: MOCK_REQUEST
      , fs :: FS.FS
      )
  )

-- | The type for integration tests.
type Test = Spec.Spec TestEffects Unit

-- | The type for the entire test suite.
type TestSuite = Eff.Eff TestEffects Unit

-- | Given a URL, a failure handler, and a success handler, create an HTTP
-- | client request.
request :: forall e.
           Boolean ->
           Int ->
           String ->
           StrMap.StrMap String ->
           String ->
           String ->
           Aff.Aff (http :: HTTP.HTTP | e) HTTPClient.Response
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

-- | Given an ST String buffer and a new string, concatenate that new string
-- | onto the ST buffer.
concat :: forall e s.
          ST.STRef s String -> String -> Eff.Eff (st :: ST.ST s | e) Unit
concat buf new = void $ ST.modifySTRef buf ((<>) new)

-- | Convert a request to an Aff containing the string with the response body.
toString :: forall e.
            HTTPClient.Response -> Aff.Aff (HTTPRequestEffects e) String
toString response = Aff.makeAff \done -> do
  let stream = HTTPClient.responseAsStream response
  buf <- ST.newSTRef ""
  Stream.onDataString stream Encoding.UTF8 $ concat buf
  Stream.onEnd stream $ ST.readSTRef buf >>= Either.Right >>> done
  pure $ Aff.nonCanceler

-- | Run an HTTP GET with the given url and return an Aff that contains the
-- | string with the response body.
get :: forall e.
       Int ->
       StrMap.StrMap String ->
       String ->
       Aff.Aff (HTTPRequestEffects e) String
get port headers path = request false port "GET" headers path "" >>= toString

-- | Run an HTTPS GET with the given url and return an Aff that contains the
-- | string with the response body.
get' :: forall e.
        Int ->
        StrMap.StrMap String ->
        String ->
        Aff.Aff (HTTPRequestEffects e) String
get' port headers path = request true port "GET" headers path "" >>= toString

-- | Run an HTTP POST with the given url and body and return an Aff that
-- | contains the string with the response body.
post :: forall e.
        Int ->
        StrMap.StrMap String ->
        String ->
        String ->
        Aff.Aff (HTTPRequestEffects e) String
post port headers path = request false port "POST" headers path >=> toString

-- | Convert a request to an Aff containing the string with the given header
-- | value.
extractHeader :: String -> HTTPClient.Response -> String
extractHeader header = unmaybe <<< lookup <<< HTTPClient.responseHeaders
  where
    unmaybe = Maybe.fromMaybe ""
    lookup = StrMap.lookup $ StringUtil.toLower header

-- | Run an HTTP GET with the given url and return an Aff that contains the
-- | string with the header value for the given header.
getHeader :: forall e.
             Int ->
             StrMap.StrMap String ->
             String ->
             String ->
             Aff.Aff (HTTPRequestEffects e) String
getHeader port headers path header =
  extractHeader header <$> request false port "GET" headers path ""

-- | An effect encapsulating creating a mock request object
foreign import data MOCK_REQUEST :: Eff.Effect

-- | Mock an HTTP Request object
foreign import mockRequestImpl ::
  forall e.
  String ->
  String ->
  String ->
  StrMap.StrMap String ->
  Eff.Eff (mockRequest :: MOCK_REQUEST | e) HTTP.Request

-- | Mock an HTTP Request object
mockRequest :: forall e.
               String ->
               String ->
               String ->
               Array (Tuple.Tuple String String) ->
               Aff.Aff (mockRequest :: MOCK_REQUEST | e) HTTP.Request
mockRequest method url body =
  EffClass.liftEff <<< mockRequestImpl method url body <<< StrMap.fromFoldable

-- | An effect encapsulating creating a mock response object
foreign import data MOCK_RESPONSE :: Eff.Effect

-- | Mock an HTTP Response object
foreign import mockResponse ::
  forall e. Eff.Eff (mockResponse :: MOCK_RESPONSE | e) HTTP.Response

-- | Get the current body from an HTTP Response object (note this will only work
-- | with an object returned from mockResponse).
getResponseBody :: HTTP.Response -> String
getResponseBody = _.body <<< Coerce.unsafeCoerce

-- | Get the currently set status from an HTTP Response object.
getResponseStatus :: HTTP.Response -> Int
getResponseStatus = _.statusCode <<< Coerce.unsafeCoerce

-- | Get all current headers on the HTTP Response object.
getResponseHeaders :: HTTP.Response -> StrMap.StrMap String
getResponseHeaders = Coerce.unsafeCoerce <<< _.headers <<< Coerce.unsafeCoerce

-- | Get the current value for the header on the HTTP Response object.
getResponseHeader :: String -> HTTP.Response -> String
getResponseHeader header =
  Maybe.fromMaybe "" <<< StrMap.lookup header <<< getResponseHeaders
