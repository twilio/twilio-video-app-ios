#!/bin/sh

# Install provisioning profiles
mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles || true
base64 -D <<< $INTERNAL_DISTRIBUTION_PROVISIONING_PROFILE -o ~/Library/MobileDevice/Provisioning\ Profiles/internal_distribution.mobileprovision
base64 -D <<< $INTERNAL_DEVELOPMENT_PROVISIONING_PROFILE -o ~/Library/MobileDevice/Provisioning\ Profiles/internal_development.mobileprovision

# Install certificates
base64 -D <<< $APPLE_WORLDWIDE_DEVELOPER_RELATIONS_CERTIFICATE_AUTHORITY_CER -o Apple\ Worldwide\ Developer\ Relations\ Certification\ Authority.cer
base64 -D <<< $TWILIO_IPHONE_DISTRIBUTION_P12 -o Certificates.p12

base64 -D <<< $APPLE_WORLDWIDE_DEVELOPER_RELATIONS_CERTIFICATE_AUTHORITY_CER -o AppleWWDRCAG3.cer

# Create a custom keychain
security create-keychain -p keychain_password ios-build.keychain

# Make the custom keychain default, so xcodebuild will use it for signing
security default-keychain -s ios-build.keychain

# Unlock the keychain
security unlock-keychain -p keychain_password ios-build.keychain

# Set keychain timeout to 2 hours for long builds
# see http://www.egeek.me/2013/02/23/jenkins-and-xcode-user-interaction-is-not-allowed/
security set-keychain-settings -t 7200 -l ~/Library/Keychains/ios-build.keychain

# Add certificates to keychain and allow codesign to access them
security import Apple\ Worldwide\ Developer\ Relations\ Certification\ Authority.cer -k ~/Library/Keychains/ios-build.keychain -A
security import AppleWWDRCAG3.cer -k ~/Library/Keychains/ios-build.keychain -A

security import Certificates.p12 -k ~/Library/Keychains/ios-build.keychain -P $TWILIO_IPHONE_DISTRIBUTION_P12_PASSWORD -A

security set-key-partition-list -S apple-tool:,apple: -k keychain_password ~/Library/Keychains/ios-build.keychain
