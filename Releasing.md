# HTTPure Releasing Guide 

1. Check out the branch you will be releasing (generally `master`, but sometimes
   an older release series branch). Ensure all relevant commits and PRs have
   been merged.
2. Update [History.md](History.md) by changing "unreleased" to the new
   version/date.  Example diff:
```diff
-unreleased
-==========
+1.0.0 / 2017-07-10
+==================
```
3. Commit your update to [History.md](History.md). Use the message "Release
   notes for v<new version number>".
4. Run `pulp version` in the project root. This will check the project for any
   issues and create a new version tag and empty checkpoint commit.
5. Push the release notes and version commit and version tag.
6. If you are pushing a non-patch release, create and push a branch named with
   the version series, i.e. `v0.1.x`.
7. [Create the release on github](https://github.com/cprussin/purescript-httpure/releases/new).
