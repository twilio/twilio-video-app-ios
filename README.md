# Twilio iOS Video App

This app is a sample video conferencing app that uses the [Twilio Programmable Video SDK](https://www.twilio.com/docs/video/ios). The open source app can be easily configured by developers to try out real-time video and audio features. Converting Objective-C code to Swift is in progress.

![room](https://user-images.githubusercontent.com/1930363/68962658-502d7f00-0792-11ea-84d2-14c5c8a704b3.png)

## Features

- [x] Video conferencing with real-time video and audio
- [x] Enable/disable camera
- [x] Switch between front and back camera
- [x] Mute/unmute mic
- [x] [Dominant speaker](https://www.twilio.com/docs/video/detecting-dominant-speaker) indicator
- [x] [Network quality](https://www.twilio.com/docs/video/using-network-quality-api) level indicator

## Requirements

iOS Deployment Target | Xcode Version | Swift Language Version
------------ | ------------- | -------------
11.0 | 11.2 | Swift 5

## Getting Started

### Install Dependencies

1. Install [CocoaPods](https://cocoapods.org).
1. Run `pod install`.

### Configure Signing

1. In Xcode navigate to the [Signing & Capabilities pane](https://developer.apple.com/documentation/xcode/adding_capabilities_to_your_app) of the project editor for the `Video-Community` target.
1. Change `Team` to your team.
1. Change `Bundle identifier` to something unique.

### Generate Twilio Access Token

1. Use the Twilio Console to [generate a Twilio Access Token](https://www.twilio.com/docs/video/tutorials/user-identity-access-tokens#generate-in-console). It is not necessary to enter a room name.
1. Replace `TWILIO_ACCESS_TOKEN` in [CommunityAuthStore.swift](https://github.com/twilio/twilio-video-app-ios/blob/master/VideoApp/VideoApp/Stores/Auth/Community/CommunityAuthStore.swift) with your Twilio access token.

This manual process for generating a Twilio access token minimizes setup but it is only useful for testing. To automate generation of Twilio access tokens for a production app see [User Identify & Access Tokens documentation](https://www.twilio.com/docs/video/tutorials/user-identity-access-tokens).

### Run

1. In Xcode use the [Scheme menu](https://developer.apple.com/library/archive/documentation/ToolsLanguages/Conceptual/Xcode_Overview/BuildingYourApp.html) to select the `Video-Community` scheme. 
1. In Xcode use the [Scheme menu](https://developer.apple.com/library/archive/documentation/ToolsLanguages/Conceptual/Xcode_Overview/BuildingYourApp.html) to select a destination. Cameras do not work in the simulator so select a device for best results.
1. Run `⌘R` the app.

The `Video-Twilio` and `Video-Internal` schemes use authentication that is only available to Twilio employees in order to make internal testing easier. 

### Start Video Conference

For each device:

1. Repeat steps to [generate a Twilio access token](#generate-twilio-access-token) (use a different identity) and [run](#run). 
1. Enter a room name.
1. Tap `Join`.

## Tests

### Unit Tests

For unit tests use:

- `Video-Twilio` scheme.
- `Video-TwilioTests` target.
- [Quick and Nimble](https://github.com/Quick/Quick) to write unit tests.
- [Swift Mock Generator](https://github.com/seanhenry/SwiftMockGeneratorForXcode) to create mocks.

### UI Tests

UI tests require credentials that are only available to Twilio employees.

### Known Issues

1. Running tests `⌘U` will crash if the app was run `⌘R` on the device previously. See issue [#12](https://github.com/twilio/twilio-video-app-ios/issues/12) for a workaround and more details.

## For Twilions

Twilio employees should follow [these instructions](ForTwilions.md) for internal testing.

## License

Apache 2.0 license. See the [LICENSE](LICENSE) file for details.
