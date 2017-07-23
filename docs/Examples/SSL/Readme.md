# SSL Example

This is a basic 'hello world' example, that runs over HTTPS. It simply returns
'hello world!' when making any request.

Note that it uses self-signed certificates, so you will need to ignore
certificate errors when testing.

To run the example server, run:

```bash
make example EXAMPLE=SSL
```
