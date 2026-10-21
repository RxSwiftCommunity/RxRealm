# Branching and releases

## Branches

- `develop` is the integration branch. Open feature and fix PRs against `develop`.
- `main` contains released code only. It changes only through a release PR from `develop`.
- Every published version is a `vX.Y.Z` tag on `main`. Tags are never moved or deleted once pushed.

Merge with merge commits, not squash or rebase, when merging `develop` into `main`, so both branches share history.

## CI

`.github/workflows/ci.yml` runs on every PR and push to `main` and `develop`:

- SwiftLint
- `swift test` on macOS
- `xcodebuild test` on iOS and tvOS simulators, and a watchOS build
- `pod lib lint`

## Cutting a release

1. On `develop`, open a PR that:
   - sets `s.version` in `RxRealm.podspec` to the new version
   - adds a `## [X.Y.Z]` section to `CHANGELOG.md`
   - updates the version in the README's installation snippet if the major version changed
2. Once that PR is merged, open a PR from `develop` into `main` titled `Release X.Y.Z`. Merge it with a merge commit when CI is green.
3. Tag the merge commit on `main` and push the tag:

   ```sh
   git switch main && git pull
   git tag -a vX.Y.Z -m "RxRealm X.Y.Z"
   git push origin vX.Y.Z
   ```

4. `.github/workflows/release.yml` checks that the tag matches the podspec version, is on `main` and has a CHANGELOG entry. It then runs the tests and creates the GitHub release with the CHANGELOG section as its notes.
5. Swift Package Manager and the [Swift Package Index](https://swiftpackageindex.com/RxSwiftCommunity/RxRealm) pick up the new tag on their own.
6. Fast-forward `develop` to `main` so the release merge commit is on both branches:

   ```sh
   git switch develop && git merge --ff-only main && git push origin develop
   ```

## CocoaPods

CocoaPods trunk becomes read-only on December 2, 2026, so publishing to trunk is a manual step done by a trunk owner (`pod trunk info RxRealm` lists them):

```sh
pod trunk push RxRealm.podspec --allow-warnings
```

To add a maintainer as a trunk owner, an existing owner runs `pod trunk add-owner RxRealm <email>`.
