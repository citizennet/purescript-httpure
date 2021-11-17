# Query Parameters Example

This is a basic example that demonstrates working with URL query parameters. It
includes an example of routing based on the _existence_ of a query parameter, an
example of routing based on the _value_ of a given query parameter, and an
example where the response is driven by the contents of a query parameter.

To run the example server, run:

```bash
nix-shell --run 'example QueryParameters'
```

Or, without nix:

```bash
spago -x test.dhall run --main Examples.QueryParameters.Main
```
