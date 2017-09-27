# Async Response Example

This is a basic 'hello world' example, that responds by asynchronously reading a
file off the filesystem. It simply returns 'hello world!' when making any
request, but the 'hello world!' text is fetched by reading the contents of the
file [Hello](./Hello).

To run the example server, run:

```bash
make example EXAMPLE=AsyncResponse
```
