0.13.0 / 2021-11-20
===================
- Ensure correct ordering on stream operations
- Add support for non-string requests (thanks **@sigma-andex**)

0.12.0 / 2021-03-20
===================
- Bump all dependency versions
- Modernize tooling
- Fix CI
- Don't use `echo -n` in example since it's nonportable to OSX

0.11.0 / 2021-03-04
===================
- Dependency version bumps
- Fix `Utils.replacePlus` to replace all occurrences (thanks **@tmciver**)
- Update to purescript 0.14 (thanks **@realvictorprm**)
- Expose original request url as a part of `Request` (thanks **@paluh**)
- Bind to 0.0.0.0 instead of 'localhost'
- Add spago configuration (thanks **@drewolson**)

0.10.0 / 2019-12-03
===================
- Update response functions to return `MonadAff m => m Repsonse` (thanks **@drewolson**)

0.9.0 / 2019-09-25
==================
- Provide utils from purescript-globals instead of FFI (thanks **@nsaunders**)
- Update the tests to work with purescript-spec v4.0.0 (thanks **Dretch**)
- Add some type declarations to get compatibility with node-buffer 6.x (thanks **Dretch**)

0.8.3 / 2019-06-03
==================
- Use `Buffer.concat` instead of string concatenation to fix ordering issues (thanks **@rnons**)

0.8.2 / 2019-05-20
==================
- Add HTTP version to `HTTPure.Request` (thanks **@joneshf**)
- Fix inconsistent case-insensitivity with `HTTPure.Headers` (thanks **@joneshf**)

0.8.0 / 2019-02-16
==================
- Re-export `HTTPure.Query` and `HTTPure.Status` (thanks **@akheron**)
- Support binary response body (thanks **@akheron**)
- Add support for chunked responses
- `ServerM` now contains a callback that when called will shut down the server
- Map empty query parameters to empty strings instead of `"true"`
- Decode percent encoding in path segments and query parameters automatically
- Use psc-package instead of bower

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
