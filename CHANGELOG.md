# Change Log

## 0.86 (November 12, 2021)

### New Feature

- Added the ability to select automatic video encoding in addition to manual video codec selection
- Enabled automatic video encoding by default in the app.

### Dependency Upgrades

- `TwilioVideo` has been updated from 4.6.2 to 4.7.0. [#178](https://github.com/twilio/twilio-video-app-ios/pull/178)

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
