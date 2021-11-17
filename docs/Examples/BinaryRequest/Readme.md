# Binary Request Example

This is a basic example of sending binary request data.  It will read in the
binary file and send back the file's sha256 checksum.

To run the server, run:

```bash
nix-shell --run 'example BinaryRequest'
```

Or, without nix:

```bash
spago -x test.dhall run --main Examples.BinaryRequest.Main
```
