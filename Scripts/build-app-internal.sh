xcodebuild \
  -workspace VideoApp.xcworkspace \
  -scheme "Video-Internal" \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 11,OS=13.0' \
| xcpretty
