# Headers Example

This is a basic example of working with headers. It will respond to an HTTP GET
on any url and will read the header 'X-Input' and return the contents in the
response body. It will also return the 'X-Example' response header with the
value 'hello world!'.

To run the example server, run:

```bash
make example EXAMPLE=Headers
```
