module HTTPure.Body
  ( Body
  , string
  , binary
  , isString
  , isBinary
  , fromString
  , fromBinary
  , read
  , write
  , size
  ) where

import Prelude

import Data.Either as Either
import Data.String as String
import Effect as Effect
import Effect.Aff as Aff
import Effect.Ref as Ref
import Node.Buffer as Buffer
import Node.Encoding as Encoding
import Node.HTTP as HTTP
import Node.Stream as Stream

-- | The `Body` type is just sugar for a `String`, that will be sent or received
-- | in the HTTP body.
data Body
  = StringBody String
  | BinaryBody Buffer.Buffer

-- | Construct a `Body` from a string
string :: String -> Body
string = StringBody

-- | Construct a `Body` from a `Buffer`
binary :: Buffer.Buffer -> Body
binary = BinaryBody

-- | Returns `true` when the `Body` is a string
isString :: Body -> Boolean
isString (StringBody _) = true
isString _ = false

-- | Returns `true` when the `Body` is binary
isBinary :: Body -> Boolean
isBinary (BinaryBody _) = true
isBinary _ = false

-- | A partial function that extracts the value from a string body.
-- | Passing a binary body will throw an error at runtime.
fromString :: Partial => Body -> String
fromString (StringBody s) = s

-- | A partial function that extracts the value from a binary body.
-- | Passing a string body will throw an error at runtime.
fromBinary :: Partial => Body -> Buffer.Buffer
fromBinary (BinaryBody b) = b

-- | Extract the contents of the body of the HTTP `Request`.
read :: HTTP.Request -> Aff.Aff String
read request = Aff.makeAff \done -> do
  let stream = HTTP.requestAsStream request
  buf <- Ref.new ""
  Stream.onDataString stream Encoding.UTF8 \str ->
    void $ Ref.modify ((<>) str) buf
  Stream.onEnd stream $ Ref.read buf >>= Either.Right >>> done
  pure $ Aff.nonCanceler

-- | Write a `Body` to the given HTTP `Response` and close it.
write :: HTTP.Response -> Body -> Effect.Effect Unit
write response body = void do
  _ <- writeToStream $ pure unit
  Stream.end stream $ pure unit
  where
    stream = HTTP.responseAsStream response
    writeToStream =
      case body of
        StringBody str -> Stream.writeString stream Encoding.UTF8 str
        BinaryBody buf -> Stream.write stream buf


size :: Body -> Effect.Effect Int
size (StringBody body) = pure $ String.length body
size (BinaryBody body) = Buffer.size body
