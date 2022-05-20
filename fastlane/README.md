fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios test

```sh
[bundle exec] fastlane ios test
```



### ios beta

```sh
[bundle exec] fastlane ios beta
```



### ios ci_match_install

```sh
[bundle exec] fastlane ios ci_match_install
```



### ios match_install

```sh
[bundle exec] fastlane ios match_install
```

Install existing match certs and profiles without updating/overwriting

### ios match_update

```sh
[bundle exec] fastlane ios match_update
```

Update and overwrite match certs and profiles if needed - destructive and may require other devs to match_install

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
