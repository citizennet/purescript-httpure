# Middleware Example

HTTPure does not have a `use` function like systems such as `express.js`, but
you can still use middlewares! This example illustrates how purely functional
middlewares in HTTPure work. It includes an example middleware that logs to the
console at the beginning and end of each request, one that injects a header into
the response, and one that handles requests to a given path.

To run the example server, run:

```bash
make example EXAMPLE=Middleware
```
