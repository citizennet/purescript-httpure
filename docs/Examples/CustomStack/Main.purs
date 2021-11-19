module Examples.CustomStack.Main where

import Prelude
import Control.Monad.Reader (class MonadAsk, ReaderT, asks, runReaderT)
import Effect.Aff (Aff)
import Effect.Aff.Class (class MonadAff)
import Effect.Console (log)
import HTTPure (Request, Response, ResponseM, ServerM, serve, ok)

-- | A type to hold the environment for our ReaderT
type Env = { name :: String }

-- | A middleware that introduces a ReaderT
readerMiddleware ::
  (Request -> ReaderT Env Aff Response) ->
  Request ->
  ResponseM
readerMiddleware router request = do
  runReaderT (router request) { name: "joe" }

-- | Say 'hello, joe' when run
sayHello :: forall m. MonadAff m => MonadAsk Env m => Request -> m Response
sayHello _ = do
  name <- asks _.name
  ok $ "hello, " <> name

-- | Boot up the server
main :: ServerM
main =
  serve 8080 (readerMiddleware sayHello) do
    log " ┌───────────────────────────────────────┐"
    log " │ Server now up on port 8080            │"
    log " │                                       │"
    log " │ To test, run:                         │"
    log " │  > curl -v localhost:8080             │"
    log " │    # => hello, joe                    │"
    log " └───────────────────────────────────────┘"
