module HTTPure.Query
  ( Query
  , read
  ) where

import Data.StrMap as StrMap
import Node.HTTP as HTTP

type Query = StrMap.StrMap String

-- | The StrMap of query segments in the given HTTP Request.
-- | TODO fill in this stub
read :: HTTP.Request -> Query
read _ = StrMap.empty
