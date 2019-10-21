# Ahoy

## Setup

### General

1. Install correct version of [CocoaPods](http://guides.cocoapods.org/using/getting-started.html). The required version is specified at the bottom of Podfile.lock.
2. Run `pod install`.
3. Create `VideoApp/VideoApp/Credentials/` directory.
4. Download `GoogleService-Info.plist` from [Firebase Console](https://firebase.google.com/docs/ios/setup#add-config-file) and copy to `VideoApp/VideoApp/Credentials/`.

### Video-Community scheme

1. Copy `VideoApp/VideoApp/CredentialsStore/Credentials.json.example` to `VideoApp/VideoApp/Credentials/CommunityCredentials.json` and add correct value for `hockey_app_identifier`. 

### Video-Internal scheme

1. Copy `VideoApp/VideoApp/CredentialsStore/Credentials.json.example` to `VideoApp/VideoApp/Credentials/InternalCredentials.json` and add correct value for `hockey_app_identifier`. 

### Video-Twilio scheme

1. Copy `VideoApp/VideoApp/CredentialsStore/Credentials.json.example` to `VideoApp/VideoApp/Credentials/TwilioCredentials.json` and add correct value for `hockey_app_identifier`. 

## Tests

Use [Swift Mock Generator](https://github.com/seanhenry/SwiftMockGeneratorForXcode) to create mocks for unit tests.
