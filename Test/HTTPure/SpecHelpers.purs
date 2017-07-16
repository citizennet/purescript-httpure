module HTTPure.SpecHelpers where

import Prelude (Unit, bind, discard, pure, unit, ($), (<>), (>>=), (<<<))

import Control.Monad.Aff as Aff
import Control.Monad.Eff as Eff
import Control.Monad.Eff.Exception as Exception
import Control.Monad.ST as ST
import Node.Encoding as Encoding
import Node.HTTP as HTTP
import Node.HTTP.Client as HTTPClient
import Node.Stream as Stream
import Node.StreamBuffer as StreamBuffer
import Test.Spec as Spec
import Test.Spec.Runner as Runner
import Unsafe.Coerce as Coerce

-- | A type alias encapsulating all effect types used in making a mock request.
type MockRequestEffects e s =
  ( st :: ST.ST s
  , exception :: Exception.EXCEPTION
  , http :: HTTP.HTTP | e
  )

-- | A type alias encapsulating all effect types used in tests.
type TestEffects s =
  Runner.RunnerEffects (
    MockRequestEffects ( sb :: StreamBuffer.STREAM_BUFFER ) s
  )

-- | The type for integration tests.
type Test = forall s. Spec.Spec (TestEffects s) Unit

-- | The type for the entire test suite.
type TestSuite = forall s. Eff.Eff (TestEffects s) Unit

-- | Given an HTTPClient.Request, close the request stream so the request can be
-- | fired.
endRequest :: forall e.
              HTTPClient.Request -> Eff.Eff (http :: HTTP.HTTP | e) Unit
endRequest request = Stream.end (HTTPClient.requestAsStream request) $ pure unit

-- | Given a URL, a failure handler, and a success handler, create an HTTP
-- | client request.
getResponse :: forall e.
               String ->
               (Exception.Error -> Eff.Eff (http :: HTTP.HTTP | e) Unit) ->
               (HTTPClient.Response -> Eff.Eff (http :: HTTP.HTTP | e) Unit) ->
               Eff.Eff (http :: HTTP.HTTP | e) Unit
getResponse url _ success = HTTPClient.requestFromURI url success >>= endRequest

-- | Given an ST String buffer and a new string, concatenate that new string
-- | onto the ST buffer.
concat :: forall e s.
          ST.STRef s String -> String -> Eff.Eff (st :: ST.ST s | e) Unit
concat buf new = ST.modifySTRef buf (\old -> old <> new) >>= (\_ -> pure unit)

-- | Convert a request to an Aff containing the string with the response body.
toString :: forall e s.
            HTTPClient.Response -> Aff.Aff (MockRequestEffects e s) String
toString response = Aff.makeAff \_ success -> do
  let stream = HTTPClient.responseAsStream response
  buf <- ST.newSTRef ""
  Stream.onDataString stream Encoding.UTF8 $ concat buf
  Stream.onEnd stream $ ST.readSTRef buf >>= success

-- | Run an HTTP GET with the given url and return an Aff that contains the
-- | string with the response body.
get :: forall e s. String -> Aff.Aff (MockRequestEffects e s) String
get url = Aff.makeAff (getResponse url) >>= toString

-- | Mock an HTTP Request object
mockRequest :: String -> String -> HTTP.Request
mockRequest method url = Coerce.unsafeCoerce { method: method, url: url }

-- | Mock an HTTP Request object
mockResponse :: forall e1.
                Stream.Writable () (sb :: StreamBuffer.STREAM_BUFFER | e1) ->
                HTTP.Response
mockResponse = Coerce.unsafeCoerce

-- | Get the currently set status from an HTTP Response object.
getResponseStatus :: HTTP.Response -> Int
getResponseStatus = _.statusCode <<< Coerce.unsafeCoerce
