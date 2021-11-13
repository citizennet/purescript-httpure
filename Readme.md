# HTTPure

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/cprussin/purescript-httpure/main/License)
[![Latest release](http://img.shields.io/github/release/cprussin/purescript-httpure.svg)](https://github.com/cprussin/purescript-httpure/releases)
[![purescript-httpure on Pursuit](https://pursuit.purescript.org/packages/purescript-httpure/badge)](https://pursuit.purescript.org/packages/purescript-httpure)

A purescript HTTP server framework.

HTTPure is:

- Well-tested (see our [tests](./test/Test))
- Well-documented (see our [documentation](./docs))
- Built to take advantage of PureScript language features for flexible and
  extensible routing
- Pure (no `set`, `get`, `use`, etc)

## Status

This project is currently fairly stable, but has not reached it's 1.0 release
yet. You can track what's left before it gets there by looking at our
[roadmap](https://github.com/cprussin/purescript-httpure/projects). The API
signatures are _mostly_ stable, but are subject to change before the 1.0 release
if there's a good reason to change them.

If you'd like to help us get to 1.0 quicker, please contribute! To get started,
check our [contributing guide](./Contributing.md).

## Installation

```bash
spago install httpure
```

## Quick Start

```purescript
module Main where

import Prelude (($))

import Effect.Console as Console
import HTTPure as HTTPure

main :: HTTPure.ServerM
main =
  HTTPure.serve 8080 router $ Console.log "Server now up on port 8080"
  where
    router _ = HTTPure.ok "hello world!"
```

## Documentation

Module documentation is published
on [Pursuit](http://pursuit.purescript.org/packages/purescript-httpure).

You can also take a look at [our guides](./docs).

## Examples

HTTPure ships with a number of [examples](./docs/Examples). To run an example,
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
the [contributing guide](Contributing.md).

## People

HTTPure is written and maintained
by [Connor Prussin](https://connor.prussin.net) and [Petri
Lehtinen](http://www.digip.org/).

We are open to accepting contributions! Please see
the [contributing guide](./Contributing.md).

## License

[MIT](./License)
