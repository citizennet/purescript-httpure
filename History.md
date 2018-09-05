unreleased
==========
- Re-export `HTTPure.Query` and `HTTPure.Status` (thanks **@akheron**)
- Support binary response body (thanks **@akheron**)
- Add support for chunked responses
- `ServerM` now contains a callback that when called will shut down the server

0.7.0 / 2018-07-08
==================
- Add support for PureScript 0.12 (thanks **@akheron**)
- Upgrade all dependencies (thanks **@akheron**)
- Use `Effect` instead of `Eff` (thanks **@akheron**)
- Use `Foreign.Object` instead of `StrMap` (thanks **@akheron**)
- Use `Effect.Ref` instead of `Control.Monad.ST` (thanks **@akheron**)
- Drop `SecureServerM`, it's the same as `ServerM` now (thanks **@akheron**)

0.6.0 / 2018-02-08
==================
- Rename `serve'` to `serveSecure`, add `serve'` and `serveSecure'`.

0.5.0 / 2017-10-25
==================
- Make ResponseM an `Aff` instead of `Eff`
- Add helpers and instances for working with headers (`Semigroup` instance,
  `HTTPure.header`, `HTTPure.empty`, etc)
- Clean up patterns for response helpers so all helpers are consistent
- Add `HTTPure.fullPath` function
- Extend `Lookup` typeclass -- make `!!` return `Maybe` types and add `!?` and
  `!@` operators.
- Add examples and guidelines for working with middlewares
- Add guides

0.4.0 / 2017-09-26
==================
- Major refactor for simpler APIs
- Lookup typeclass and `!!` operator
- Support for inspecting and routing on path segments
- Support for inspecting and routing on query parameters

0.3.0 / 2017-08-01
==================
- Support HTTPS servers

0.2.0 / 2017-07-20
==================
- Support all HTTP response statuses
- Support all HTTP request methods
  - Added in v0.1.0
    - Get
    - Post
    - Put
    - Delete
  - New
    - Head
    - Connect
    - Options
    - Trace
    - Patch

0.1.0 / 2017-07-17
==================
- Support OK response
- Support Get, Post, Put, and Delete HTTP methods
- Support sending and reading headers and body
