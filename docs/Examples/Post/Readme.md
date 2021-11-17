# Post Example

This is a basic example of handling a Post. It will respond to a HTTP POST on
any path with the post body in the response body.

To run the example server, run:

```bash
nix-shell --run 'example Post'
```

Or, without nix:

```bash
spago -x test.dhall run --main Examples.Post.Main
```
