source 'git@github.com:twilio/cocoapod-specs-internal.git'
source 'https://cdn.cocoapods.org/'

platform :ios, '12.0'
use_frameworks!
workspace 'VideoApp'

target 'Video-Internal' do
  project 'VideoApp/VideoApp.xcodeproj'

  pod 'Alamofire', '5.0.2'
  pod 'AppCenter/Distribute', '2.5.3'
  pod 'Crashlytics', '3.14.0'
  pod 'Firebase/Analytics', '6.14.0'
  pod 'FirebaseUI/Auth', '8.4.0'
  pod 'FirebaseUI/Google', '8.4.0'
  pod 'IGListDiffKit', '4.0.0'
  pod 'KeychainAccess', '4.1.0'
  pod 'TwilioVideo', '4.0.0-2f37b4ba'

  target 'Video-InternalTests' do
    pod 'Nimble'
    pod 'Quick'

    target 'Video-CommunityTests' do
      # Identical to Video-InternalTests
    end
  end

  target 'Video-Community' do
    # Identical to Video-Twilio
  end
end

# Don't inherit pods like other targets for good black box testing
target 'Video-InternalUITests' do
  project 'VideoApp/VideoApp.xcodeproj'

  pod 'Nimble'
end
