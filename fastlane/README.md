fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew install fastlane`

# Available Actions
## iOS
### ios test
```
fastlane ios test
```

### ios beta
```
fastlane ios beta
```

### ios ci_match_install
```
fastlane ios ci_match_install
```

### ios match_install
```
fastlane ios match_install
```
Install existing match certs and profiles without updating/overwriting
### ios match_update
```
fastlane ios match_update
```
Update and overwrite match certs and profiles if needed - destructive and may require other devs to match_install

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
