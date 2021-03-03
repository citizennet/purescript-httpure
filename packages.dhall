let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.14.0-20210302/packages.dhall sha256:20cc5b89cf15433623ad6f250f112bf7a6bd82b5972363ecff4abf1febb02c50

let overrides = {=}

let additions = {=}

in  upstream // overrides // additions
