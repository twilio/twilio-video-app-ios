source 'https://cdn.cocoapods.org/'

platform :ios, '12.2'
inhibit_all_warnings!
use_frameworks!
workspace 'VideoApp'

target 'Video-Internal' do
  project 'VideoApp/VideoApp.xcodeproj'

  pod 'Alamofire', '~> 5'
  pod 'AppCenter/Distribute', '~> 4'
  pod 'Firebase/Analytics', '~> 8'
  pod 'Firebase/Crashlytics', '~> 8'
  pod 'FirebaseUI/Auth', '~> 12'
  pod 'FirebaseUI/Google', '~> 12'
  pod 'IGListDiffKit', '~> 4'
  pod 'KeychainAccess', '~> 4'
  pod 'TwilioVideo', '~> 5'

  target 'Video-InternalTests' do
    pod 'Nimble', '~> 9'
    pod 'Quick', '~> 3'

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

  pod 'Nimble', '~> 9'
end

# Fix lots of build warnings: https://github.com/CocoaPods/CocoaPods/issues/9884
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
    end
  end
end
