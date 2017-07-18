module HTTPure.SpecHelpers where

import Prelude

import Control.Monad.Aff as Aff
import Control.Monad.Eff as Eff
import Control.Monad.Eff.Exception as Exception
import Control.Monad.ST as ST
import Data.Maybe as Maybe
import Data.String as StringUtil
import Data.StrMap as StrMap
import Node.Encoding as Encoding
import Node.HTTP as HTTP
import Node.HTTP.Client as HTTPClient
import Node.Stream as Stream
import Test.Spec as Spec
import Test.Spec.Runner as Runner
import Unsafe.Coerce as Coerce

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
      )
  )

-- | The type for integration tests.
type Test = Spec.Spec TestEffects Unit

-- | The type for the entire test suite.
type TestSuite = Eff.Eff TestEffects Unit

-- | Given an HTTPClient.Request, close the request stream so the request can be
-- | fired.
endRequest :: forall e.
              HTTPClient.Request -> Eff.Eff (http :: HTTP.HTTP | e) Unit
endRequest request = Stream.end (HTTPClient.requestAsStream request) $ pure unit

-- | Given a URL, a failure handler, and a success handler, create an HTTP
-- | client request.
getResponse :: forall e.
               String ->
               Aff.Aff (http :: HTTP.HTTP | e) HTTPClient.Response
getResponse url = Aff.makeAff \_ success ->
  HTTPClient.requestFromURI url success >>= endRequest

-- | Given an ST String buffer and a new string, concatenate that new string
-- | onto the ST buffer.
concat :: forall e s.
          ST.STRef s String -> String -> Eff.Eff (st :: ST.ST s | e) Unit
concat buf new = ST.modifySTRef buf (\old -> old <> new) >>= (\_ -> pure unit)

-- | Convert a request to an Aff containing the string with the response body.
toString :: forall e.
            HTTPClient.Response -> Aff.Aff (HTTPRequestEffects e) String
toString response = Aff.makeAff \_ success -> do
  let stream = HTTPClient.responseAsStream response
  buf <- ST.newSTRef ""
  Stream.onDataString stream Encoding.UTF8 $ concat buf
  Stream.onEnd stream $ ST.readSTRef buf >>= success

-- | Run an HTTP GET with the given url and return an Aff that contains the
-- | string with the response body.
get :: forall e. String -> Aff.Aff (HTTPRequestEffects e) String
get url = getResponse url >>= toString

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
             String ->
             String ->
             Aff.Aff (HTTPRequestEffects e) String
getHeader url header = extractHeader header <$> getResponse url

-- | An effect encapsulating creating a mock request object
foreign import data MOCK_REQUEST :: Eff.Effect

-- | Mock an HTTP Request object
foreign import mockRequest ::
  forall e.
  String ->
  String ->
  String ->
  StrMap.StrMap String ->
  Eff.Eff (mockRequest :: MOCK_REQUEST | e) HTTP.Request

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
