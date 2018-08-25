module HTTPure.Streamable
  ( class Streamable
  , toStream
  ) where

import Node.Buffer as Buffer
import Node.Stream as Stream

foreign import createStreamFromString :: String -> Stream.Readable ()
foreign import createStreamFromBuffer :: Buffer.Buffer -> Stream.Readable ()

class Streamable s where
  toStream :: s -> Stream.Readable ()

instance streamableString :: Streamable String where
  toStream = createStreamFromString

instance streamableBuffer :: Streamable Buffer.Buffer where
  toStream = createStreamFromBuffer
