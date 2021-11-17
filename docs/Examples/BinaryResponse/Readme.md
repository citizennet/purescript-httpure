# Binary Response Example

This is a basic example of sending binary response data.  It serves an image
file as binary data on any URL.

To run the server, run:

```bash
nix-shell --run 'example BinaryResponse'
```

Or, without nix:

```bash
spago -x test.dhall run --main Examples.BinaryResponse.Main
```
