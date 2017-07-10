# HTTPure Contributing Guide

Welcome to HTTPure! We would love contributions from the community. Please
follow this guide when creating contributions to help make the project better!

## Logging Issues

If you find a bug or a place where documentation needs to be improved, or if you
have a feature request,
please
[submit an issue](https://github.com/cprussin/purescript-httpure/issues/new)! In
issues you submit, please be clear, and preferably have code examples indicating
what is broken, needs improvement, or what your requested API should look like.

## Contributions

All contributions to this repository should come in the form of pull requests.
All pull requests must be reviewed before being merged. Please follow these
steps for creating a successful PR:

1. [Create an issue](https://github.com/cprussin/purescript-httpure/issues/new)
   for your contribution.
2. [Create a fork](https://github.com/cprussin/purescript-httpure) on github.
3. Create a branch in your fork for your contribution.
4. Add your contribution to the source tree.
5. Run the test suite. All tests MUST pass for a PR to be accepted.
6. Push your code and create a PR on github. Please make sure to reference your
   issue number in your PR description.

Branch all work off the `master` branch. In the future, we will create branches
for specific release series, and `master` will be used for the current stable
release series.

### Documentation

For the most part, HTTPure's documentation is intended to be consumed
through [Pursuit](http://pursuit.purescript.org/packages/purescript-httpure). To
this end, documentation should mostly be provided inline in the codebase, and
should follow the same PR process as other commits.

We also welcome documentation in the form of guides and examples. These should
live in the [Documentation](Documentation) directory. Please ensure all guides
are written in markdown format, and all examples are fully-functional and
implemented as self-contained subdirectories
under [Documentation/Examples](Documentation/Examples).

All examples should have corresponding integration tests, to ensure that
examples we promote remain functional. If you plan to contribute examples,
please take a look at [IntegrationSpec.purs](Test/HTTPure/IntegrationSpec.purs).

### Code

Code should follow existing styles and all code should be accompanied with
relevant unit/integration tests. If you fix a bug, write a test. If you write a
new feature, write a test.

All tests MUST pass for your PR to be accepted. If you break a test, either fix
the test or fix the code.
