# HTTPure

A purescript HTTP server framework.

## Status

This project is currently an early-stage work in progress. It is not
production-ready yet. You can track what's left before it gets production-ready
by looking at
our [roadmap](https://github.com/cprussin/purescript-httpure/projects). If you'd
like to help us get there quicker, please contribute! To get started, check
our [contributing guide](CONTRIBUTING.md).

## Installation

```bash
bower install --save purescript-httpure
```

## Quick Start

```purescript
module Main where

import Prelude (map, ($))

import Control.Monad.Eff.Console as Console
import HTTPure as HTTPure

main :: HTTPure.HTTPureM (console :: Console.CONSOLE)
main = do
  HTTPure.serve 8080 routes $ Console.log "Server now up on port 8080"
  where
    routes = map HTTPure.Route
      [ { method: HTTPure.Get
        , route: "/"
        , body: \_ -> "hello world!"
        }
      ]
```

## Documentation

Module documentation is published
on [Pursuit](http://pursuit.purescript.org/packages/purescript-httpure).

## Examples

HTTPure ships with a number of [examples](docs/examples). To run an example,
in the project root, run:

```bash
make example EXAMPLE=<Example Name>
```

Each example's startup banner will include information on routes available on
the example server.

## Testing

To run the test suite, in the project root run:

```bash
make test
```

## Contributing

We are open to accepting contributions! Please see
the [contributing guide](CONTRIBUTING.md).

## People

HTTPure is written and maintained
by [Connor Prussin](https://connor.prussin.net).

We are open to accepting contributions! Please see
the [contributing guide](CONTRIBUTING.md).

## License

[MIT](LICENSE)
