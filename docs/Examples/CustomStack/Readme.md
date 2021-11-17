# CustomStack Example

This example demonstrates using middleware to introduce a custom monad stack
to your application. Here, we run our router within a `ReaderT` to provide a
globally-available environment during routing.

To run the example server, run:

```bash
nix-shell --run 'example CustomStack'
```

Or, without nix:

```bash
spago -x test.dhall run --main Examples.CustomStack.Main
```
