# Change Log

## 0.1.17 (September 30, 2022)

### Maintenance

- Updated Video iOS SDK version to 5.2.1.

## 0.1.16 (August 24, 2022)

### Maintenance

- Updated Video iOS SDK version to 5.2.0.

## 0.1.15 (June 3, 2022)

### Maintenance

- Switch from CocoaPods to Swift Package Manager.
- Burned some app version numbers getting CI to build the release using Swift Package Manager.

## 0.1.9 (April 21, 2022)

### Maintenance

- Improve release process used for internal testing.
- Use semantic versioning for the app version number.

## 0.95 (March 31, 2022)

### New Features

- Started using `SwiftUI` to build a better app with a lot less code. If you want to use code from this repo in a `UIKit` app, see [these tips](https://github.com/twilio/twilio-video-app-ios#swiftui). 
- Added speaker grid layout to show participant video in a grid. The grid supports pagination and users can swipe to switch between grid pages. The most recent dominant speakers are automatically displayed on the first page of the grid.
- Added presenter layout that displays the most recent dominant speaker. If a user is sharing their screen it also displays the screen presentation.
- Removed old video layout that had a main video view and list of participants. This is replaced by the new grid and presenter layouts.
- New UI styling for all features except sign in and app settings.

## 0.91 (March 15, 2022)

### New Feature

- Extend the `VideoCodec` enumeration to include `.auto` (which maps to `VideoEncodingMode.auto` in the SDK). 
- Introduce `VideoSize` - a setting to select the size of video published from the camera
- The settings `.vp8SimulcastVGA` and `.vp8SimulcastHD` are condensed into `.vp8Simulcast`. 
- The `Video-Internal` target now enables `.auto` by default by setting the new Connect Option `videoEncodingMode` to `.auto`.

### Dependency Upgrades

- `TwilioVideo` has been updated from 5.0.0 to 5.1.0. https://github.com/twilio/twilio-video-ios/releases/tag/5.1.0

-----------

## 0.89 (February 14, 2022)

### Dependency Upgrades

- `TwilioVideo` has been updated from 4.6.3 to 5.0.0. [#187](https://github.com/twilio/twilio-video-app-ios/pull/187)

## 0.88 (January 13, 2022)

### Maintenance

- Updated the internal build variant to use the same REST interface for the token endpoint as the community build. 
- Removed topology setting that was only used by internal build.
- Simplified error handling for REST requests.

-----------

## 0.87 (December 13, 2021)

### Dependency Upgrades

- `TwilioVideo` has been updated from 4.6.2 to 4.6.3. [#180](https://github.com/twilio/twilio-video-app-ios/pull/180)

-----------

## 0.86 (December 10, 2021)

- Updated repo to use Fastlane match for provisioning.

-----------
## 0.85 (November 5, 2021)

### Dependency Upgrades

- `TwilioVideo` has been updated from 4.6.1 to 4.6.2. [#177](https://github.com/twilio/twilio-video-app-ios/pull/177)

-----------

## 0.84 (October 15, 2021)

### Dependency Upgrades

- `TwilioVideo` has been updated from 4.6.0 to 4.6.1. [#176](https://github.com/twilio/twilio-video-app-ios/pull/176)

-----------

## 0.82 (September 20, 2021)

### New Feature

- This release adds support for Apple Silicon arm64 Macs. You can now run the iOS and iPad OS simulators on your Mac in addition to testing on physical devices.
- TwilioVideo [4.6.0](https://www.twilio.com/docs/video/changelog-twilio-video-ios-latest#460-september-17-2021) also updates WebRTC to M88 and modernizes the use of several WebRTC APIs.

### Dependency Upgrades

- Several dependencies were updated in order to support the iOS and iPadOS simulators on Apple Silicon machines.
- `AppCenter/Distribute` has been updated from 3.3.4 to 4.3.0. [#174](https://github.com/twilio/twilio-video-app-ios/pull/174)
- `Firebase/Analytics` has been updated from 6.34.0 to 8.7.0. [#174](https://github.com/twilio/twilio-video-app-ios/pull/174)
- `Firebase/Crashlytics` has been updated from 6.34.0 to 8.7.0. [#174](https://github.com/twilio/twilio-video-app-ios/pull/174)
- `FirebaseUI/Auth` has been updated from 9.0.0 to 12.0.2. [#174](https://github.com/twilio/twilio-video-app-ios/pull/174)
- `FirebaseUI/Google` has been updated from 9.0.0 to 12.0.2. [#174](https://github.com/twilio/twilio-video-app-ios/pull/174)
- `TwilioVideo` has been updated from 4.5.0 to 4.6.0. [#174](https://github.com/twilio/twilio-video-app-ios/pull/174)

-----------

## 0.81 (August 27, 2021)

### New Feature

- Added support for Client Track Switch Off and Video Content Preferences.
- Improved `UICollectionView` cell management so that tracks are switched off immediately when cells are offscreen.
- We recommend that you review the [ParticipantCell](https://github.com/twilio/twilio-video-app-ios/blob/v0.81/VideoApp/VideoApp/Views/Cells/Participant/ParticipantCell.swift) and [VideoView](https://github.com/twilio/twilio-video-app-ios/blob/v0.81/VideoApp/VideoApp/Views/VideoView/VideoView.swift) implementations if you use `UICollectionView` and want to update your application for Client Track Switch Off.
- For more information, please view this [blog post](https://www.twilio.com/blog/improve-efficiency-multi-party-video-experiences) and feature [documentation](https://www.twilio.com/docs/video/tutorials/using-bandwidth-profile-api#understanding-clientTrackSwitchOffControl).

### Bugs

- Fixed a visual issue where the `UICollectionView` had leading space to its superview.

### Maintenance

- Removed support for the deprectated `maxTracks` and `renderDimensions` properties in `VideoBandwidthProfileOptions`.

### Dependency Upgrades

- `TwilioVideo` has been updated from 4.4.0 to 4.5.0, and 4.5.0 is now the minimum required version. [#169](https://github.com/twilio/twilio-video-app-ios/pull/169)

-----------

## 0.1.0

This release marks the first iteration of the Twilio Video Collaboration App: a multi-party collaboration video application built with Programmable Video. This application is intended to demonstrate the capabilities of Programmable Video and serve as a reference to developers building video apps. 

This initial release comes with the following features:

- Join rooms with up to 50 participants
- Toggle local media: camera and mic
- Show a Room’s dominant speaker in the primary video view
- Show a participant’s network quality

We look forward to collaborating with the community!
