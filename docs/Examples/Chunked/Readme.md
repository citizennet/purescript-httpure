# Chunked Example

This is a basic example of sending chunked data.  It will return 'hello world'
in two separate chunks spaced a second apart on any URL.

To run the example server, run:

```bash
nix-shell --run 'example Chunked'
```

Or, without nix:

```bash
spago -x test.dhall run --main Examples.Chunked.Main
```
