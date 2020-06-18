# For Twilions

Twilio employees should follow these instructions for internal testing.

## Getting Started

### Install Dependencies

1. Run `gem install bundler` to install [Bundler](https://bundler.io/). Bundler ensures everyone is using the same CocoaPods version.
1. Run `bundle install` to install the required CocoaPods version.
1. Run `bundle exec pod install` to install pod dependencies.

### Secrets

1. Ask a buddy for `IOSVideoAppSecrets.tar` and extract to the root directory of repo.

### Run

1. Select `Video-Internal` scheme.
1. Run `⌘R` the app.

## UI Tests

For UI tests use:

- `Video-InternalUITests` scheme.
- `Video-InternalUITests` target. 
- `UI` test plan.
- [Nimble](https://github.com/Quick/Quick) for assertions.
