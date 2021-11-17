# Hello World Example

This is a basic 'hello world' example. It simply returns 'hello world!' when
making any request.

To run the example server, run:

```bash
nix-shell --run 'example HelloWorld'
```

Or, without nix:

```bash
spago -x test.dhall run --main Examples.HelloWorld.Main
```
