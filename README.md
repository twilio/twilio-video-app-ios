# Ahoy

## Setup

### General

1. Install [Bundler](https://bundler.io/).
1. Run `bundle exec pod install`.
1. Create `VideoApp/VideoApp/Credentials/` directory.
1. Download `GoogleService-Info.plist` from [Firebase Console](https://firebase.google.com/docs/ios/setup#add-config-file) and copy to `VideoApp/VideoApp/Credentials/`.

### Video-Community scheme

1. Copy `VideoApp/VideoApp/CredentialsStore/Credentials.json.example` to `VideoApp/VideoApp/Credentials/CommunityCredentials.json` and add correct value for `hockey_app_identifier`. 

### Video-Internal scheme

1. Copy `VideoApp/VideoApp/CredentialsStore/Credentials.json.example` to `VideoApp/VideoApp/Credentials/InternalCredentials.json` and add correct value for `hockey_app_identifier`. 

### Video-Twilio scheme

1. Copy `VideoApp/VideoApp/CredentialsStore/Credentials.json.example` to `VideoApp/VideoApp/Credentials/TwilioCredentials.json` and add correct value for `hockey_app_identifier`. 

## Tests

Use [Swift Mock Generator](https://github.com/seanhenry/SwiftMockGeneratorForXcode) to create mocks for unit tests.
