# HTTPure Releasing Guide

1. Check out the release series branch (or `main` if you are releasing the next 
   major/minor version). Ensure all relevant commits and PRs have been merged.
2. Update [History.md](./History.md) by changing "unreleased" to the new
   version/date.  Example diff:
```diff
-unreleased
-==========
+1.0.0 / 2017-07-10
+==================
```
3. Commit your update to [History.md](./History.md). Use the message `Release
   notes for v<new version number>`.
4. Follow the instructions on
   https://discourse.purescript.org/t/how-i-publish-a-purescript-package/2482.
5. If you are pushing a non-patch release, create and push a branch named with
   the version series, i.e. `v0.1.x`.
6. [Create the release on
   github](https://github.com/cprussin/purescript-httpure/releases/new).
