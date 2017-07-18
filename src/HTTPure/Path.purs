module HTTPure.Path
  ( Path
  ) where

-- | The Path type is just sugar for a String that will be sent in a request and
-- | indicates the path of the resource being requested.
type Path = String
