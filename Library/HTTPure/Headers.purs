module HTTPure.Headers
  ( Headers
  ) where

import Data.StrMap as StrMap

-- | The Headers type is just sugar for a StrMap of Strings that represents the
-- | set of headers sent or received in an HTTP request or response.
type Headers = StrMap.StrMap String
