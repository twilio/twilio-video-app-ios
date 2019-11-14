## Twilio iOS Video App

This app is a sample video conferencing app that uses [Twilio's Programmable Video SDK](https://www.twilio.com/docs/video/ios). Twilio uses the app internally for testing. The open source app can be easily configured by external developers to try out real-time video and audio features. The project is mostly Objective-C but we are converting to Swift!

![room](https://user-images.githubusercontent.com/1930363/68900838-f2e1f100-06f1-11ea-8ac6-7c154fa5ee2f.png)

## Features

- [x] Video conferencing with real-time video and audio
- [x] Enable/disable camera
- [x] Switch between front and back camera
- [x] Mute/unmute mic
- [x] Dominant speaker indicator
- [x] Network quality level indicator

## Requirements

iOS Deployment Target | Xcode Version | Swift Language Version
------------ | ------------- | -------------
11.0 | 11.2 | Swift 5

## Getting Started

### Install Dependencies

1. Run `gem install bundler` to install [Bundler](https://bundler.io/).
1. Run `bundle install` to install the required version of [CocoaPods](https://cocoapods.org).
1. Run `bundle exec pod install` to install pod dependencies.

### Configure Signing

1. In Xcode navigate to the [Signing & Capabilities pane](https://developer.apple.com/documentation/xcode/adding_capabilities_to_your_app) of the project editor for the `Video-Community` target.
1. Change `Team` to your team.
1. Change `Bundle identifier` to something unique.

### Generate Twilio Access Token

1. Use the Twilio Console to [generate a Twilio Access Token](https://www.twilio.com/docs/video/tutorials/user-identity-access-tokens#generate-in-console). It is not necessary to enter a room name.
1. Replace `TWILIO_ACCESS_TOKEN` in [CommunityAuthStore.swift](https://github.com/twilio/twilio-video-app-ios/blob/master/VideoApp/VideoApp/Stores/Auth/Community/CommunityAuthStore.swift) with your Twilio access token.

### Run

1. In Xcode use the [scheme menu](https://developer.apple.com/library/archive/documentation/ToolsLanguages/Conceptual/Xcode_Overview/BuildingYourApp.html) to select the `Video-Community` scheme. 
1. In Xcode use the [scheme menu](https://developer.apple.com/library/archive/documentation/ToolsLanguages/Conceptual/Xcode_Overview/BuildingYourApp.html) to select a destination. Not all features work in the simulator so select a device for best results.
1. Run `⌘R` the app.

### Start video conference

For each device:

1. Repeat steps to generate a Twilio access token and run. 
1. Enter a room name.
1. Tap `Join`.

## Unit Tests

### How to Test

- Use the `Video-TwilioTests` target. 
- Use [Quick and Nimble](https://github.com/Quick/Quick) to write unit tests.
- Use [Swift Mock Generator](https://github.com/seanhenry/SwiftMockGeneratorForXcode) to create mocks.

### Known Issues

1. Running tests `⌘U` will crash if the app was run `⌘R` on the device previously. See issue [#12](https://github.com/twilio/twilio-video-app-ios/issues/12) for a workaround and more details.

## Contribute

Check out the [CONTRIBUTING](CONTRIBUTING.md) file for information on how to help with this app.

## License

Apache 2.0 license. See the [LICENSE](LICENSE) file for details.
