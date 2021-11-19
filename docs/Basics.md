# HTTPure Basics

This guide is a brief overview of the basics of creating a HTTPure server.

## Creating a Server

To create a server, use `HTTPure.serve` (no SSL) or `HTTPure.serveSecure` (SSL).
Both of these functions take a port number, a router function, and an `Effect`
that will run once the server has booted. The signature of the router function
is:

```purescript
HTTPure.Request -> HTTPure.ResponseM
```

For more details on routing, see the [Routing guide](./Routing.md). For more
details on responses, see the [Responses guide](./Responses.md). The router can
be composed with middleware; for more details, see the [Middleware
guide](./Middleware.md).

## Non-SSL

You can create an HTTPure server without SSL using `HTTPure.serve`:

```purescript
main :: HTTPure.ServerM
main = HTTPure.serve 8080 router $ log "Server up"
```

Most of the [examples](./Examples), besides [the SSL Example](./Examples/SSL),
use this method to create the server.

You can also create a server using a custom
[`HTTP.ListenOptions`](http://bit.ly/2G42rLd) value:

```purescript
main :: HTTPure.ServerM
main = HTTPure.serve' customOptions router $ log "Server up"
```

## SSL

You can create an SSL-enabled HTTPure server using `HTTPure.serveSecure`, which
has the same signature as `HTTPure.serve` except that it additionally takes a
path to a cert file and a path to a key file after the port number:

```purescript
main :: HTTPure.ServerM
main =
  HTTPure.serveSecure 8080 "./Certificate.cer" "./Key.key" router $
    log "Server up"
```

You can look at [the SSL Example](./Examples/SSL/Main.purs), which uses this
method to create the server.

You can also create a server using a
[`HTTP.ListenOptions`](http://bit.ly/2G42rLd) and a
[`HTTPS.SSLOptions`](http://bit.ly/2G3Aljr):

```purescript
main :: HTTPure.ServerM
main =
  HTTPure.serveSecure' customSSLOptions customOptions router $
    log "Server up"
```

## Shutdown hook

To gracefully shut down a server you can add a shutdown hook. For this you will need to add the following dependencies:

```
posix-types
node-process
``` 

Then take the closing handler returned by `serve` and create a `SIGINT` and `SIGTERM` hook:

```purescript
import Prelude

import Data.Posix.Signal (Signal(SIGINT, SIGTERM))
import Effect (Effect)
import Effect.Console (log)
import HTTPure (serve, ok)
import Node.Process (onSignal)

main :: Effect Unit
main = do 
  closingHandler <- serve 8080 (const $ ok "hello world!") do
    log $ "Server now up on port 8080"

  onSignal SIGINT $ closingHandler $ log "Received SIGINT, stopping service now."
  onSignal SIGTERM $ closingHandler $ log "Received SIGTERM, stopping service now."
```
