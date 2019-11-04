# Ahoy

## Setup

### General

1. Install correct version of [CocoaPods](http://guides.cocoapods.org/using/getting-started.html). The required version is specified at the bottom of Podfile.lock.
2. Run `pod install`.
3. Create `VideoApp/VideoApp/Credentials/` directory.
4. Download `GoogleService-Info.plist` from [Firebase Console](https://firebase.google.com/docs/ios/setup#add-config-file) and copy to `VideoApp/VideoApp/Credentials/`.

### Video-Community Scheme

1. Copy `VideoApp/VideoApp/CredentialsStore/Credentials.json.example` to `VideoApp/VideoApp/Credentials/CommunityCredentials.json` and add correct value for `hockey_app_identifier`. 

### Video-Internal Scheme

1. Copy `VideoApp/VideoApp/CredentialsStore/Credentials.json.example` to `VideoApp/VideoApp/Credentials/InternalCredentials.json` and add correct value for `hockey_app_identifier`. 

### Video-Twilio Scheme

1. Copy `VideoApp/VideoApp/CredentialsStore/Credentials.json.example` to `VideoApp/VideoApp/Credentials/TwilioCredentials.json` and add correct value for `hockey_app_identifier`. 

## Tests

Use [Swift Mock Generator](https://github.com/seanhenry/SwiftMockGeneratorForXcode) to create mocks for unit tests.

## Known Issues

1. Running tests `⌘U` will crash if the app was run `⌘R` on the device previously. To fix this delete the app and then run tests. The problem seems to be caused by `application(_:configurationForConnecting:options:)` not always getting called at launch.
