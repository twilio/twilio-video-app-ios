# Twilio Video iOS App

This app is a sample video conferencing app that uses the [Twilio Programmable Video SDK](https://www.twilio.com/docs/video/ios). The open source app can be easily configured by developers to try out real-time video and audio features. 

![video-app-screenshots](https://user-images.githubusercontent.com/1930363/76462720-c2f8e080-63a7-11ea-9b15-d4326636c42c.png)

## Features

- [x] Video conferencing with real-time video and audio
- [x] Enable/disable camera
- [x] Mute/unmute mic
- [x] Switch between front and back camera
- [x] [Dominant speaker](https://www.twilio.com/docs/video/detecting-dominant-speaker) indicator
- [x] [Network quality](https://www.twilio.com/docs/video/using-network-quality-api) indicator
- [x] [Bandwidth Profile API](https://www.twilio.com/docs/video/tutorials/using-bandwidth-profile-api)

## Requirements

iOS Deployment Target | Xcode Version | Swift Language Version
------------ | ------------- | -------------
11.0 | 11.3 | Swift 5

## Getting Started

### Deploy Twilio Access Token Server

**NOTE:** The Twilio Function that provides access tokens via a passcode should *NOT* be used in a production environment. This token server supports seamlessly getting started with the collaboration app, and while convenient, the passcode is not secure enough for production environments. You should use an authentication provider to securely provide access tokens to your client applications. You can find more information about Programmable Video access tokens [in this tutorial](https://www.twilio.com/docs/video/tutorials/user-identity-access-tokens).

The app requires a back-end to generate [Twilio access tokens](https://www.twilio.com/docs/video/tutorials/user-identity-access-tokens). Follow the instructions below to deploy a serverless back-end using [Twilio Functions](https://www.twilio.com/docs/runtime/functions).

1. [Install Twilio CLI](https://www.twilio.com/docs/twilio-cli/quickstart).
1. Run `twilio login` and follow prompts to [login to your Twilio account](https://www.twilio.com/docs/twilio-cli/quickstart#login-to-your-twilio-account).
1. Run `twilio plugins:install @twilio-labs/plugin-rtc`.
1. Run `twilio rtc:apps:video:deploy --authentication passcode`.
1. The passcode that is output will be used later to [sign in to the app](#start-video-conference).

The passcode will expire after one week. To generate a new passcode, run `twilio rtc:apps:video:deploy --authentication passcode --override`.

#### Troubleshooting The Twilio CLI

If any errors occur after running a [Twilio CLI RTC Plugin](https://github.com/twilio-labs/plugin-rtc) command, then try the following steps.

1. Run `twilio plugins:update` to update the rtc plugin to the latest version.
1. Run `twilio rtc:apps:video:delete` to delete any existing authentication servers.
1. Run `twilio rtc:apps:video:deploy --authentication passcode` to deploy a new authentication server.

### Install Dependencies

1. Install [CocoaPods](https://cocoapods.org).
1. Run `pod install`.

### Configure Signing

1. Open `VideoApp.xcworkspace` with Xcode.
1. In Xcode navigate to the [Signing & Capabilities pane](https://developer.apple.com/documentation/xcode/adding_capabilities_to_your_app) of the project editor for the `Video-Community` target.
1. Change `Team` to your team.
1. Change `Bundle identifier` to something unique.

### Run

1. In Xcode use the [Scheme menu](https://developer.apple.com/library/archive/documentation/ToolsLanguages/Conceptual/Xcode_Overview/BuildingYourApp.html) to select the `Video-Community` scheme. 
1. In Xcode use the [Scheme menu](https://developer.apple.com/library/archive/documentation/ToolsLanguages/Conceptual/Xcode_Overview/BuildingYourApp.html) to select a destination. Cameras do not work in the simulator so select a device for best results.
1. Run `⌘R` the app.

The `Video-Internal` scheme uses authentication that is only available to Twilio employees in order to make internal testing easier. 

### Start Video Conference

For each device:

1. [Run](#run) the app.
1. Enter any unique name in the `Your name` field.
1. Enter the passcode from [Deploy Twilio Access Token Server](#deploy-twilio-access-token-server) in the `Passcode` field.
1. Tap `Sign in`.
1. Enter a room name.
1. Tap `Join`.

The passcode will expire after one week. Follow the steps below to sign in with a new passcode.

1. [Generate a new passcode](#deploy-twilio-access-token-server).
1. In the app tap `Settings > Sign Out`.
1. Repeat the [steps above](#start-video-conference).

## Tests

### Unit Tests

For unit tests use:

- `Video-Internal` scheme.
- `Video-InternalTests` target.
- `Unit` test plan.
- [Quick and Nimble](https://github.com/Quick/Quick) to write unit tests.
- [Swift Mock Generator](https://github.com/seanhenry/SwiftMockGeneratorForXcode) to create mocks.

### UI Tests

UI tests require credentials that are only available to Twilio employees.

### Known Issues

1. Running tests `⌘U` will crash if the app was run `⌘R` on the device previously. See issue [#12](https://github.com/twilio/twilio-video-app-ios/issues/12) for a workaround and more details.

## Related

- [Twilio Video Android App](https://github.com/twilio/twilio-video-app-android)
- [Twilio Video React App](https://github.com/twilio/twilio-video-app-react)
- [Twilio CLI RTC Plugin](https://github.com/twilio-labs/plugin-rtc)

## For Twilions

Twilio employees should follow [these instructions](ForTwilions.md) for internal testing.

## License

Apache 2.0 license. See the [LICENSE](LICENSE) file for details.
