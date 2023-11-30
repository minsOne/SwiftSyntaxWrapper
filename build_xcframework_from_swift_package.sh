#!/bin/zsh -x

# reference : https://developer.apple.com/forums/thread/741100
# see https://stackoverflow.com/questions/72920519/turn-package-swift-file-into-binary-xcframework

PACKAGE_DIRECTORY=$1
SCHEME=$2
FRAMEWORK_RELATIVE_DIRECTORY=$3

CONFIGURATION=Release

# Value is ignored, only the definition of the variable is considered
#
export SPM_GENERATE_FRAMEWORK=1

function buildframework {


### Build/Intermediates.noindex/SwiftPackageTest.build/Release-iphoneos/SwiftPackageTest.build/Objects-normal/arm64/SwiftPackageTest-Swift.h

	# build package as framework
	#
    (cd $PACKAGE_DIRECTORY && xcodebuild -scheme $1 -destination $2 -sdk $3 -configuration $CONFIGURATION -derivedDataPath "${FRAMEWORK_DIRECTORY}/.build" \
    	SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES OTHER_SWIFT_FLAGS="-no-verify-emitted-module-interface" SYMROOT="$FRAMEWORK_DIRECTORY") || exit -1

#     (cd $PACKAGE_DIRECTORY && xcodebuild archive -scheme $1 -destination $2 -sdk $3 -archivePath $1.xcarchive -configuration $CONFIGURATION \
#     	SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES OTHER_SWIFT_FLAGS=-no-verify-emitted-module-interface ) || exit -1

   BUILD_PATH=$FRAMEWORK_DIRECTORY/${CONFIGURATION}-${3}
   BUILD_FRAMEWORK_PATH=$BUILD_PATH/PackageFrameworks/${SCHEME}.framework/
   BUILD_FRAMEWORK_HEADERS=$BUILD_FRAMEWORK_PATH/Headers

   mkdir $BUILD_FRAMEWORK_HEADERS
   SWIFT_HEADER="${FRAMEWORK_DIRECTORY}/.build/Build/Intermediates.noindex/$1.build/${CONFIGURATION}-${3}/$1.build/Objects-normal/arm64/${1}-Swift.h"

   if [ -f "$SWIFT_HEADER" ]
   then
       cp -p $SWIFT_HEADER $BUILD_FRAMEWORK_HEADERS || exit -2
   fi

   # copy package headers (if any) to generated framework
   #
   PACKAGE_INCLUDE_DIRS=$(find $PACKAGE_DIRECTORY -path "*/Sources/*/include" -type d)

   if [ -n "$PACKAGE_INCLUDE_DIRS" ]
   then
       cp -prv $PACKAGE_DIRECTORY/Sources/*/include/* $BUILD_FRAMEWORK_HEADERS || exit -2
   fi
   
   # handle swiftmodule or modulemap file
   #
   mkdir $BUILD_FRAMEWORK_PATH/Modules
   
   SWIFT_MODULE_DIRECTORY=$BUILD_PATH/${1}.swiftmodule
   
   if [ -d $SWIFT_MODULE_DIRECTORY ]
   then
   		cp -prv $SWIFT_MODULE_DIRECTORY $BUILD_FRAMEWORK_PATH/Modules
   else
       # create module.modulemap file
	   echo "framework module $SCHEME {
umbrella \"Headers\"
export *

module * { export * }
}"     > $BUILD_FRAMEWORK_PATH/Modules/module.modulemap
	fi

   # Copy bundle
   BUNDLE_DIRECTORY=$BUILD_PATH/${1}_${1}.bundle
   if [ -d $BUNDLE_DIRECTORY ]
   then
       cp -prv $BUNDLE_DIRECTORY $BUILD_FRAMEWORK_PATH
   fi

}

##
##

mkdir -p $FRAMEWORK_RELATIVE_DIRECTORY
FRAMEWORK_DIRECTORY=`readlink -f $FRAMEWORK_RELATIVE_DIRECTORY`

buildframework $SCHEME "generic/platform=iOS" "iphoneos"
buildframework $SCHEME "generic/platform=iOS Simulator" "iphonesimulator"
buildframework $SCHEME "generic/platform=MacOS" "macosx14.0"

xcodebuild -create-xcframework \
        -framework "${FRAMEWORK_DIRECTORY}/${CONFIGURATION}-iphoneos/PackageFrameworks/${SCHEME}.framework" \
        -framework "${FRAMEWORK_DIRECTORY}/${CONFIGURATION}-iphonesimulator/PackageFrameworks/${SCHEME}.framework" \
        -framework "${FRAMEWORK_DIRECTORY}/${CONFIGURATION}-macos/PackageFrameworks/${SCHEME}.framework" \
        -output "${FRAMEWORK_DIRECTORY}/${SCHEME}.xcframework"
