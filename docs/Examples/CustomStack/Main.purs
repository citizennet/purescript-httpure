module Examples.CustomStack.Main where

import Prelude
import Control.Monad.Reader (class MonadAsk, ReaderT, asks, runReaderT)
import Effect.Aff (Aff)
import Effect.Aff.Class (class MonadAff)
import Effect.Console as Console
import HTTPure as HTTPure

-- | A type to hold the environment for our ReaderT
type Env
  = { name :: String
    }

-- | A middleware that introduces a ReaderT
readerMiddleware ::
  (HTTPure.Request -> ReaderT Env Aff HTTPure.Response) ->
  HTTPure.Request ->
  HTTPure.ResponseM
readerMiddleware router request = do
  runReaderT (router request) { name: "joe" }

-- | Say 'hello, joe' when run
sayHello :: forall m. MonadAff m => MonadAsk Env m => HTTPure.Request -> m HTTPure.Response
sayHello _ = do
  name <- asks _.name
  HTTPure.ok $ "hello, " <> name

-- | Boot up the server
main :: HTTPure.ServerM
main =
  HTTPure.serve 8080 (readerMiddleware sayHello) do
    Console.log $ " ┌───────────────────────────────────────┐"
    Console.log $ " │ Server now up on port 8080            │"
    Console.log $ " │                                       │"
    Console.log $ " │ To test, run:                         │"
    Console.log $ " │  > curl -v localhost:8080             │"
    Console.log $ " │    # => hello, joe                    │"
    Console.log $ " └───────────────────────────────────────┘"
