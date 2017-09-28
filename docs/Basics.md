# HTTPure Basics

This guide is a brief overview of the basics of creating a HTTPure server.

## Creating a Server

To create a server, use `HTTPure.serve` (no SSL) or `HTTPure.serve'` (SSL). Both
of these functions take a port number, a router function, and an `Eff` that will
run once the server has booted. The signature of the router function is:

```purescript
forall e. HTTPure.Request -> HTTPure.ResponseM e
```

For more details on routing, see the [Routing guide](./Routing.md). For more
details on responses, see the [Responses guide](./Responses.md). The router can
be composed with middleware; for more details, see the [Middleware
guide](./Middleware.md).

## Non-SSL

You can create an HTTPure server without SSL using `HTTPure.serve`:

```purescript
main = HTTPure.serve 8080 router $ Console.log "Server up"
```

Most of the [examples](./Examples), besides [the SSL Example](./Examples/SSL),
use this method to create the server.

## SSL

You can create an SSL-enabled HTTPure server using `HTTPure.serve'`, which has
the same signature as `HTTPure.serve` except that it additionally takes a path
to a cert file and a path to a key file after the port number:

```purescript
main =
  HTTPure.serve 8080 "./Certificate.cer" "./Key.key" router $
    Console.log "Server up"
```

You can look at [the SSL Example](./Examples/SSL/Main.purs), which uses this
method to create the server.
