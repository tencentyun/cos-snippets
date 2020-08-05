#!/bin/sh

xcodebuild \
  -workspace COS_Swift_Test.xcworkspace \
  -scheme COS_Swift_Test \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,OS=11.3,name=iPhone X' \
  test | xcpretty
