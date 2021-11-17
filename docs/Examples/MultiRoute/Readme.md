# Multi Route Example

This is a basic example that shows how to create multiple basic routes. It will
return 'hello' when requesting /hello with an HTTP GET, and it will return
'goodbye' when requesting /goodbye with an HTTP GET.

To run the example server, run:

```bash
nix-shell --run 'example MultiRoute'
```

Or, without nix:

```bash
spago -x test.dhall run --main Examples.MultiRoute.Main
```
