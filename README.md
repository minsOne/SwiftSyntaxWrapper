# SwiftSyntaxWrapper

```
# Scipio 설치
# https://giginet.github.io/Scipio/documentation/scipio/installation

$ scipio create SwiftSyntaxWrapper
```

```shell
$ xcrun xcodebuild archive \
  -workspace . \
  -scheme SwiftSyntaxWrapper \
  -configuration Release \
  -destination 'generic/platform=iOS' \
  -derivedDataPath '.build' \
  -archivePath './.build/Release/SwiftSyntaxWrapper-iphoneos.xcarchive' \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

$ xcrun xcodebuild archive \
  -workspace . \
  -scheme SwiftSyntaxWrapper \
  -configuration Release \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath '.build' \
  -archivePath './.build/Release/SwiftSyntaxWrapper-iphonesimulator.xcarchive' \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

$ xcrun xcodebuild archive \
  -workspace . \
  -scheme SwiftSyntaxWrapper \
  -configuration Release \
  -destination 'generic/platform=MacOS' \
  -derivedDataPath '.build' \
  -archivePath './.build/Release/SwiftSyntaxWrapper-macos.xcarchive' \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

$ xcodebuild -create-xcframework \
  -framework "./.build/Release/SwiftSyntaxWrapper-iphoneos.xcarchive/Products/usr/local/lib/SwiftSyntaxWrapper.framework" \
  -framework "./.build/Release/SwiftSyntaxWrapper-iphonesimulator.xcarchive/Products/usr/local/lib/SwiftSyntaxWrapper.framework" \
  -framework "./.build/Release/SwiftSyntaxWrapper-macos.xcarchive/Products/usr/local/lib/SwiftSyntaxWrapper.framework" \
  -output "SwiftSyntaxWrapper.xcframework"

// OR
$ make all
```

### Reference

* Swift Forums - [How to build Swift Package as XCFramework](https://forums.swift.org/t/how-to-build-swift-package-as-xcframework/41414/28)