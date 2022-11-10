# Headers Example

This is a basic example of working with headers. It will respond to an HTTP GET
on any url and will read the header 'X-Input' and return the contents in the
response body. It will also return the 'X-Example' response header with the
value 'hello world!'.

Bear in mind that acessing `Set-Cookie` headers through the `headers` interface
will not work because of how node.js represents those headers specifically. For
`Set-Cookie` request headers, please use the `multiHeaders` property of
`HTTPure.Request`.

To run the example server, run:

```bash
nix-shell --run 'example Headers'
```

Or, without nix:

```bash
spago -x test.dhall run --main Examples.Headers.Main
```
