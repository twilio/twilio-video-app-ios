#!/bin/bash -e

# source `dirname $0`/env.sh
pushd "$(pwd)"

# Check to see if IOS_APP is set, if not, crash and burn
if [ "${IOS_APP}" = "RTCRoomsDemo" ]; then
  echo "Building RTCRoomsDemo"
  APP_DIR="RTCRoomsDemo-iOS"
  APP_SCHEME="RTCRoomsDemo"
  PROJECT_FILE="RTCRoomsDemo-iOS/RTCRoomsDemo.xcodeproj/project.pbxproj"
  SCHEME_FILE="RTCRoomsDemo-iOS/RTCRoomsDemo.xcodeproj/xcshareddata/xcschemes/RTCRoomsDemo.xcscheme"
  EXPORT_OPTIONS_PLIST="RTCRoomsDemo-iOS/RTCRoomsDemo/ExportOptions/enterprise.plist"
elif [ "${IOS_APP}" = "VideoApp-Internal" ]; then
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
else
  echo "Unknown app"
  exit 1
fi

# if [ "${TWILIO_CI}" = "true" ]; then
# # If we are running in a CI environment, we will need to download the framework and expand it before we can build.
#   mkdir -p ${ZIP_DIR}
#   aws s3 cp --quiet $AWS_BUILD_URL/${CONFIGURATION}/${CONFIGURATION}-universal-TwilioVideo.zip ${ZIP_DIR}
#   mkdir -p ${UNIVERSAL_OUTPUTFOLDER}
#   unzip -q -o ${ZIP_DIR}/${CONFIGURATION}-universal-TwilioVideo.zip -d ${UNIVERSAL_OUTPUTFOLDER}

#   # And we need to alter some files a wee bit...
#   BACKUP_DIR=${TEMP_DIR}/Backup/${APP_DIR}
#   mkdir -p ${BACKUP_DIR}

#   # Mangle the project file
#   cp ${PROJECT_FILE} ${BACKUP_DIR}

#   # 1. Use the universal framework we already built...
#   sed -i "" "s:path = TwilioVideo.framework; sourceTree = BUILT_PRODUCTS_DIR; };:name = TwilioVideo.framework; path = \"${UNIVERSAL_OUTPUTFOLDER}/TwilioVideo.framework\"; sourceTree = \"<absolute>\"; };:g" ${PROJECT_FILE}

#   # 2. Add it to the FRAMEWORK_SEARCH_PATHS
#   sed -i "" "s:\"\$(PROJECT_DIR)/Carthage/Build/iOS\",:\"\$(PROJECT_DIR)/Carthage/Build/iOS\",\
# 					\"${UNIVERSAL_OUTPUTFOLDER}\",:g" ${PROJECT_FILE}

#   # 3. If we are a debug build, disable BITCODE
#   if [ "${CONFIGURATION}" = "Debug" ]; then
#     sed -i "" 's/FRAMEWORK_SEARCH_PATHS/ENABLE_BITCODE = NO;\
# 				FRAMEWORK_SEARCH_PATHS/g' ${PROJECT_FILE}
#   fi

#   # Mangle the scheme file
#   cp ${SCHEME_FILE} ${BACKUP_DIR}
#   sed -E -i "" 's/buildImplicitDependencies = "YES"/buildImplicitDependencies = "NO"/g' ${SCHEME_FILE}
# fi

WORKSPACE=VideoApp.xcworkspace
# ARCHIVE_PATH="${ARCHIVE_DIR}/${APP_SCHEME}.xcarchive"

# pushd "${APP_DIR}"
#   ./Scripts/carthage-dependencies.sh
# popd

BITCODE_MODE=marker
# if [ "${CONFIGURATION}" = "Release" ]; then
#   BITCODE_MODE=bitcode
# fi

# mkdir -p ${ARCHIVE_PATH}
# mkdir -p ${IPA_DIR}

# xcodebuild \
#   -workspace ${WORKSPACE} \
#   -scheme ${APP_SCHEME} \
#   -derivedDataPath ${DERIVED_DATA_DIR} \
#   -configuration ${CONFIGURATION} \
#   -sdk iphoneos \
#   -parallelizeTargets \
#   ${TWILIO_XCODE_QUIET_ON_CI} \
#   -archivePath "${ARCHIVE_PATH}" \
#   ONLY_ACTIVE_ARCH=NO \
#   BITCODE_GENERATION_MODE=${BITCODE_MODE} \
#   archive

# xcodebuild \
#   -exportArchive \
#   -archivePath "${ARCHIVE_PATH}" \
#   -exportPath "${IPA_DIR}" \
#   -exportOptionsPlist ${EXPORT_OPTIONS_PLIST}

xcodebuild \
  -workspace ${WORKSPACE} \
  -scheme ${APP_SCHEME} \
  -configuration "Debug" \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 11,OS=13.0' \
  -parallelizeTargets \
  ONLY_ACTIVE_ARCH=YES \
  BITCODE_GENERATION_MODE=${BITCODE_MODE} \
  test \
| xcpretty \

# If we are running in a CI environment, upload the artifacts to AWS
# if [ "${TWILIO_CI}" = "true" ]; then
#   mkdir -p "${ZIP_DIR}"

#   # For the simulator...
#   pushd ${BUILD_DIR}/${CONFIGURATION}-iphonesimulator
#     zip --quiet -r "${ZIP_DIR}/${CONFIGURATION}-iphonesimulator-${APP_SCHEME}.zip" ${APP_SCHEME}*
#   popd

#   # For the device...
#   pushd ${IPA_DIR}
#     zip --quiet -r "${ZIP_DIR}/${CONFIGURATION}-iphoneos-${APP_SCHEME}.zip" ${APP_SCHEME}.ipa
#   popd

#   pushd ${ARCHIVE_DIR}
#     # Prepare the dSYM.zip artifact
#     pushd ${APP_SCHEME}.xcarchive/dSYMs
#       zip --quiet -r "${APP_SCHEME}-dSYMs.zip" *.dSYM
#       zip --quiet -r "${ZIP_DIR}/${CONFIGURATION}-iphoneos-${APP_SCHEME}.zip" "${APP_SCHEME}-dSYMs.zip"
#     popd

#     zip --quiet -r "${ZIP_DIR}/${CONFIGURATION}-iphoneos-${APP_SCHEME}.zip" ${APP_SCHEME}.xcarchive
#   popd

#   # AWS Upload the things
#   aws s3 cp --quiet ${ZIP_DIR}/${CONFIGURATION}-iphonesimulator-${APP_SCHEME}.zip $AWS_BUILD_URL/${CONFIGURATION}/
#   aws s3 cp --quiet ${ZIP_DIR}/${CONFIGURATION}-iphoneos-${APP_SCHEME}.zip $AWS_BUILD_URL/${CONFIGURATION}/

#   # Put things back the way they were
#   cp ${BACKUP_DIR}/project.pbxproj ${PROJECT_FILE}
#   cp ${BACKUP_DIR}/${APP_SCHEME}.xcscheme ${SCHEME_FILE}
# fi

popd

