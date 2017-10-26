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
