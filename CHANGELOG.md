# Change Log

## 0.81 (August 27, 2021)

### New Feature

- Added support for Client Track Switch Off and Video Content Preferences
- Improved `UICollectionView` cell management so that tracks are switched off immediately when cells are offscreen.
- We recommend that you review the [ParticipantCell](https://github.com/twilio/twilio-video-app-ios/blob/v0.81/VideoApp/VideoApp/Views/Cells/Participant/ParticipantCell.swift) and [VideoView](https://github.com/twilio/twilio-video-app-ios/blob/v0.81/VideoApp/VideoApp/Views/VideoView/VideoView.swift) implementations if you use `UICollectionView` and want to update your application for Client Track Switch Off.
- For more information, please view this [blog post](https://www.twilio.com/blog/improve-efficiency-multi-party-video-experiences) and feature [documentation](https://www.twilio.com/docs/video/tutorials/using-bandwidth-profile-api#understanding-clientTrackSwitchOffControl).

### Bugs

- Fixed a visual issue where the `UICollectionView` had leading space to its superview

### Maintenance

- Removed support for the deprectated `maxTracks` and `renderDimensions` properties in `VideoBandwidthProfileOptions`.

### Dependency Upgrades

- `twilio-video-ios` has been updated from 4.4.0 to 4.5.0, and 4.5.0 is now the minimum required version. [#169](https://github.com/twilio/twilio-video-app-ios/pull/169)

-----------

## 0.1.0

This release marks the first iteration of the Twilio Video Collaboration App: a multi-party collaboration video application built with Programmable Video. This application is intended to demonstrate the capabilities of Programmable Video and serve as a reference to developers building video apps. 

This initial release comes with the following features:

- Join rooms with up to 50 participants
- Toggle local media: camera and mic
- Show a Room’s dominant speaker in the primary video view
- Show a participant’s network quality

We look forward to collaborating with the community!
