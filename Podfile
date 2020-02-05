platform :ios, '11.0'
use_frameworks!
workspace 'VideoApp'

target 'Video-Twilio' do
  project 'VideoApp/VideoApp.xcodeproj'

  pod 'AppCenter/Distribute', '2.5.3'
  pod 'Crashlytics', '3.14.0'
  pod 'TwilioVideo', '~> 3.2'
  pod 'Firebase/Analytics', '6.14.0'
  pod 'FirebaseUI/Auth', '8.4.0'
  pod 'FirebaseUI/Google', '8.4.0'

  target 'Video-TwilioTests' do
    pod 'Nimble'
    pod 'Quick'

    target 'Video-InternalTests' do
      # Identical to Video-TwilioTests
    end

    target 'Video-CommunityTests' do
      # Identical to Video-TwilioTests
    end
  end

  target 'Video-Internal' do
    # Identical to Video-Twilio
  end

  target 'Video-Community' do
    # Identical to Video-Twilio
  end
end

# Don't inherit pods like other targets for good black box testing
target 'Video-TwilioUITests' do
  project 'VideoApp/VideoApp.xcodeproj'

  pod 'Nimble'
end
