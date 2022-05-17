# For Twilions

Twilio employees should follow these instructions for internal testing.

## Getting Started

### Secrets

1. Ask a buddy for `IOSVideoAppSecrets.tar` and extract to the root directory of repo.
1. Follow [iOS Fastlane Match Setup](https://wiki.hq.twilio.com/display/SDK/iOS+Fastlane+Match+Setup) instructions to set up Fastlane Match.

### Run

1. Select `Video-Internal` scheme.
1. Run `⌘R` the app.

## Release

1. Merge work to `master` branch.
1. Make sure `CHANGELOG.md` contains the correct release notes.
1. Create a release in GitHub. Use app version for the tag name, such as `1.8.2`. Copy release notes from `CHANGELOG.md`. 
1. CI will automatically build the release and upload it to App Center. 
