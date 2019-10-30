#!/bin/bash -e

# source `dirname $0`/env.sh
pushd "$(pwd)"

# Check to see if IOS_APP is set, if not, crash and burn
if [ "${IOS_APP}" = "VideoApp-Internal" ]; then
  echo "Building VideoApp"
  APP_DIR="VideoApp"
  APP_SCHEME="Video-Internal"
  PROJECT_FILE="VideoApp/VideoApp.xcodeproj/project.pbxproj"
  SCHEME_FILE="VideoApp/VideoApp.xcodeproj/xcshareddata/xcschemes/Video-Internal.xcscheme"
  EXPORT_OPTIONS_PLIST="VideoApp/VideoApp/ExportOptions/enterprise.plist"
elif [ "${IOS_APP}" = "VideoApp-Twilio" ]; then
  echo "Building VideoApp"
  APP_DIR="VideoApp"
  APP_SCHEME="Video-Twilio"
  PROJECT_FILE="VideoApp/VideoApp.xcodeproj/project.pbxproj"
  SCHEME_FILE="VideoApp/VideoApp.xcodeproj/xcshareddata/xcschemes/Video-Twilio.xcscheme"
  # EXPORT_OPTIONS_PLIST="VideoApp/VideoApp/ExportOptions/enterprise.plist"
elif [ "${IOS_APP}" = "VideoApp-Community" ]; then
  echo "Building VideoApp"
  APP_DIR="VideoApp"
  APP_SCHEME="Video-Community"
  PROJECT_FILE="VideoApp/VideoApp.xcodeproj/project.pbxproj"
  SCHEME_FILE="VideoApp/VideoApp.xcodeproj/xcshareddata/xcschemes/Video-Twilio.xcscheme"
  # EXPORT_OPTIONS_PLIST="VideoApp/VideoApp/ExportOptions/enterprise.plist"
else
  echo "Unknown app"
  exit 1
fi

BITCODE_MODE=marker
# if [ "${CONFIGURATION}" = "Release" ]; then
#   BITCODE_MODE=bitcode
# fi

xcodebuild \
  -workspace VideoApp.xcworkspace \
  -scheme ${APP_SCHEME} \
  -configuration "Debug" \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 11,OS=13.0' \
  -parallelizeTargets \
  ONLY_ACTIVE_ARCH=YES \
  BITCODE_GENERATION_MODE=${BITCODE_MODE} \
  test \
| xcpretty \

popd
