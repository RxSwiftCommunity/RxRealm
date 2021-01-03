#!/usr/bin/env bash

set -euo pipefail
rm -rf xcarchives/*
rm -rf RxRealm.xcframework

xcodebuild archive -project RxRealm.xcodeproj -scheme "RxRealm iOS" -sdk iphoneos -archivePath "xcarchives/RxRealm-iOS" clean
# xcodebuild archive -project RxRealm.xcodeproj -scheme "RxRealm iOS" -sdk iphonesimulator  -archivePath "xcarchives/RxRealm-iOS-Simulator" 
xcodebuild archive -project RxRealm.xcodeproj -scheme "RxRealm tvOS" -sdk appletvos -archivePath "xcarchives/RxRealm-tvOS" clean
# xcodebuild archive -project RxRealm.xcodeproj -scheme "RxRealm tvOS" -sdk appletvsimulator -archivePath "xcarchives/RxRealm-tvOS-Simulator" 
xcodebuild archive -project RxRealm.xcodeproj -scheme "RxRealm macOS" -sdk macosx -archivePath "xcarchives/RxRealm-macOS" clean
xcodebuild archive -project RxRealm.xcodeproj -scheme "RxRealm watchOS" -sdk watchos -archivePath "xcarchives/RxRealm-watchOS" clean 
# xcodebuild archive -project RxRealm.xcodeproj -scheme "RxRealm watchOS" -sdk watchsimulator -archivePath "xcarchives/RxRealm-watchOS-Simulator" 

xcodebuild -create-xcframework \
-framework "xcarchives/RxRealm-iOS.xcarchive/Products/Library/Frameworks/RxRealm.framework" \
-debug-symbols ""$(pwd)"/xcarchives/RxRealm-iOS.xcarchive/dSYMs/RxRealm.framework.dSYM" \
-framework "xcarchives/RxRealm-tvOS.xcarchive/Products/Library/Frameworks/RxRealm.framework" \
-debug-symbols ""$(pwd)"/xcarchives/RxRealm-tvOS.xcarchive/dSYMs/RxRealm.framework.dSYM" \
-framework "xcarchives/RxRealm-macOS.xcarchive/Products/Library/Frameworks/RxRealm.framework" \
-debug-symbols ""$(pwd)"/xcarchives/RxRealm-macOS.xcarchive/dSYMs/RxRealm.framework.dSYM" \
-framework "xcarchives/RxRealm-watchOS.xcarchive/Products/Library/Frameworks/RxRealm.framework" \
-debug-symbols ""$(pwd)"/xcarchives/RxRealm-watchOS.xcarchive/dSYMs/RxRealm.framework.dSYM" \
-output "RxRealm.xcframework" 

zip -r RxRealm.xcframework.zip RxRealm.xcframework
rm -rf xcarchives/*
rm -rf RxRealm.xcframework