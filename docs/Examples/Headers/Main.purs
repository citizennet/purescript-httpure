module Examples.Headers.Main where

import Prelude
import Effect.Console (log)
import HTTPure (ServerM, Headers, Request, ResponseM, (!@), header, serve, ok')

-- | The headers that will be included in every response.
responseHeaders :: Headers
responseHeaders = header "X-Example" "hello world!"

-- | Route to the correct handler
router :: Request -> ResponseM
router { headers } = ok' responseHeaders $ headers !@ "X-Input"

-- | Boot up the server
main :: ServerM
main =
  serve 8080 router do
    log " ┌──────────────────────────────────────────────┐"
    log " │ Server now up on port 8080                   │"
    log " │                                              │"
    log " │ To test, run:                                │"
    log " │  > curl -H 'X-Input: test' -v localhost:8080 │"
    log " │    # => ...                                  │"
    log " │    # => ...< X-Example: hello world!         │"
    log " │    # => ...                                  │"
    log " │    # => test                                 │"
    log " └──────────────────────────────────────────────┘"
