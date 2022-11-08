module Examples.MultiHeaders.Main where

import Prelude

import Data.Foldable as Data.Foldable
import Data.Maybe (maybe)
import Data.Tuple (Tuple(..))
import Effect.Console (log)
import HTTPure (MultiHeaders, Request, ResponseM, ServerM, ok, serve, (!!))
import HTTPure.MultiHeaders as HTTPure.MultiHeaders

-- | The headers that will be included in every response.
responseHeaders :: MultiHeaders
responseHeaders =
  HTTPure.MultiHeaders.headers
    [ Tuple "Set-Cookie" "id=123456"
    , Tuple "Set-Cookie" "domain=foo.example.com"
    ]

-- | Route to the correct handler
router :: Request -> ResponseM
router { multiHeaders } = ado
  response <-
    ok
      $ maybe "" (Data.Foldable.intercalate ", ")
      $ multiHeaders !! "X-Input"
  in response { multiHeaders = responseHeaders }

-- | Boot up the server
main :: ServerM
main =
  serve 8080 router do
    log " ┌───────────────────────────────────────────────────────────────────┐"
    log " │ Server now up on port 8080                                        │"
    log " │                                                                   │"
    log " │ To test, run:                                                     │"
    log " │  > curl -H 'X-Input: test1' -H 'X-Input: test2' -v localhost:8080 │"
    log " │    # => ...                                                       │"
    log " │    # => ...< Set-Cookie: id=123456                                │"
    log " │    # => ...< Set-Cookie: domain=foo.example.com                   │"
    log " │    # => ...                                                       │"
    log " │    # => test1, test2                                              │"
    log " └───────────────────────────────────────────────────────────────────┘"
