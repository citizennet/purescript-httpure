# Multi-Headers Example

This is a basic example of working with multi-headers. Unlike `HTTPure.Headers`,
the `HTTPure.MultiHeaders` module abstracts headers with potentially multiple
values.

This example will respond to an HTTP GET on any url and will read the header
'X-Input' and return the contents in the response body. Try adding multiple,
duplicate 'X-Input' headers to see how it works. It will also return the
'Set-Cookie' response header with multiple values.

To run the example server, run:

```bash
nix-shell --run 'example MultiHeaders'
```

Or, without nix:

```bash
spago -x test.dhall run --main Examples.MultiHeaders.Main
```
