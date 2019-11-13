# Ahoy

## Setup

### General

1. Install [Bundler](https://bundler.io/).
1. Run 'bundle install`.
1. Run `bundle exec pod install`.

### Video-Twilio and Video-Internal Schemes

1. Create `VideoApp/VideoApp/Credentials/` directory.
1. Download `GoogleService-Info.plist` from [Firebase Console](https://firebase.google.com/docs/ios/setup#add-config-file) and copy to `VideoApp/VideoApp/Credentials/`.

## Tests

Use [Swift Mock Generator](https://github.com/seanhenry/SwiftMockGeneratorForXcode) to create mocks for unit tests.

## Known Issues

1. Running tests `⌘U` will crash if the app was run `⌘R` on the device previously. To fix this delete the app and then run tests. The problem seems to be caused by `application(_:configurationForConnecting:options:)` not always getting called at launch.
