# HTTPure

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/cprussin/purescript-httpure/master/License)
[![Latest release](http://img.shields.io/github/release/cprussin/purescript-httpure.svg)](https://github.com/cprussin/purescript-httpure/releases)
[![Build Status](https://travis-ci.org/cprussin/purescript-httpure.svg?branch=master)](https://travis-ci.org/cprussin/purescript-httpure)

A purescript HTTP server framework.

## Status

This project is currently an early-stage work in progress. It is not
production-ready yet. You can track what's left before it gets production-ready
by looking at
our [roadmap](https://github.com/cprussin/purescript-httpure/projects). If you'd
like to help us get there quicker, please contribute! To get started, check
our [contributing guide](Contributing.md).

## Installation

```bash
bower install --save purescript-httpure
```

## Quick Start

```purescript
module Main where

import Prelude (pure, ($))

import Control.Monad.Eff.Console as Console
import Data.StrMap as StrMap
import HTTPure as HTTPure

main :: HTTPure.ServerM (console :: Console.CONSOLE)
main = do
  HTTPure.serve 8080 router $ Console.log "Server now up on port 8080"
  where
    router _ = pure $ HTTPure.OK StrMap.empty "hello world!"
```

## Documentation

Module documentation is published
on [Pursuit](http://pursuit.purescript.org/packages/purescript-httpure).

## Examples

HTTPure ships with a number of [examples](Documentation/Examples). To run an
example, in the project root, run:

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
by [Connor Prussin](https://connor.prussin.net).

We are open to accepting contributions! Please see
the [contributing guide](Contributing.md).

## License

[MIT](License)
