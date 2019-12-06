platform :ios, '11.0'

use_frameworks!

workspace 'VideoApp'

target 'Video-Twilio' do
  project 'VideoApp/VideoApp.xcodeproj'

  pod 'TwilioVideo'
  pod 'Firebase/Analytics', '~> 4.10'
  pod 'FirebaseUI/Auth'
  pod 'FirebaseUI/Google'

  target 'Video-TwilioTests' do
    pod 'Nimble'
    pod 'Quick'
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
