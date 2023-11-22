.PHONY: all build-iphoneos build-iphonesimulator build-macos create-xcframework

SCHEME = SwiftSyntaxWrapper
OS_IOS = iphoneos
OS_IOS_SIMULATOR = iphonesimulator
OS_MACOS = macos

DESTINATION_IOS = 'generic/platform=iOS'
DESTINATION_IOS_SIMULATOR = 'generic/platform=iOS Simulator'
DESTINATION_MACOS = 'generic/platform=MacOS'

ARCHIVE_PATH_IOS = ./.build/Release/$(SCHEME)-$(OS_IOS).xcarchive
ARCHIVE_PATH_IOS_SIMULATOR = ./.build/Release/$(SCHEME)-$(OS_IOS_SIMULATOR).xcarchive
ARCHIVE_PATH_MACOS = ./.build/Release/$(SCHEME)-$(OS_MACOS).xcarchive
FRAMEWORK_PATH_IOS = $(ARCHIVE_PATH_IOS)/Products/usr/local/lib/$(SCHEME).framework
FRAMEWORK_PATH_IOS_SIMULATOR = $(ARCHIVE_PATH_IOS_SIMULATOR)/Products/usr/local/lib/$(SCHEME).framework
FRAMEWORK_PATH_MACOS = $(ARCHIVE_PATH_MACOS)/Products/usr/local/lib/$(SCHEME).framework
XCFRAMEWORK_OUTPUT = ./build/$(SCHEME).xcframework

SWIFTMODULE_SOURCE = .build/Build/Intermediates.noindex/ArchiveIntermediates
SWIFTMODULE_SOURCE_IOS = $(SWIFTMODULE_SOURCE)/$(SCHEME)/BuildProductsPath/Release-$(OS_IOS)/$(SCHEME).swiftmodule
SWIFTMODULE_SOURCE_IOS_SIMULATOR = $(SWIFTMODULE_SOURCE)/$(SCHEME)/BuildProductsPath/Release-$(OS_IOS_SIMULATOR)/$(SCHEME).swiftmodule
SWIFTMODULE_SOURCE_MACOS = $(SWIFTMODULE_SOURCE)/$(SCHEME)/BuildProductsPath/Release/$(SCHEME).swiftmodule

MODULEMAP_SOURCE = .build/Build/Intermediates.noindex/ArchiveIntermediates/$(SCHEME)/IntermediateBuildFilesPath/$(SCHEME).build
MODULEMAP_SOURCE_IOS = $(MODULEMAP_SOURCE)/Release-$(OS_IOS)/$(SCHEME).build/$(SCHEME).modulemap
MODULEMAP_SOURCE_IOS_SIMULATOR = $(MODULEMAP_SOURCE)/Release-$(OS_IOS_SIMULATOR)/$(SCHEME).build/$(SCHEME).modulemap
MODULEMAP_SOURCE_MACOS = $(MODULEMAP_SOURCE)/Release/$(SCHEME).build/$(SCHEME).modulemap

SWIFTHEADER_SOURCE = .build/Build/Intermediates.noindex/ArchiveIntermediates/$(SCHEME)/IntermediateBuildFilesPath/$(SCHEME).build
SWIFTHEADER_SOURCE_IOS = $(SWIFTHEADER_SOURCE)/Release-$(OS_IOS)/$(SCHEME).build/Objects-normal/arm64/$(SCHEME)-Swift.h
SWIFTHEADER_SOURCE_IOS_SIMULATOR = $(SWIFTHEADER_SOURCE)/Release-$(OS_IOS_SIMULATOR)/$(SCHEME).build/Objects-normal/arm64/$(SCHEME)-Swift.h
SWIFTHEADER_SOURCE_MACOS = $(SWIFTHEADER_SOURCE)/Release/$(SCHEME).build/Objects-normal/arm64/$(SCHEME)-Swift.h

MODULEMAP_TXT = "\
framework module SwiftSyntaxWrapper {\n \
umbrella header "SwiftSyntaxWrapper-Swift.h"\n \
export *\n \
module * { export * }\n
}"

define copy_swiftmodule
	mkdir -p $(2)/Products/usr/local/lib/$(SCHEME).framework/Modules
	cp -r $(1) $(2)/Products/usr/local/lib/$(SCHEME).framework/Modules/$(SCHEME).swiftmodule
endef

define copy_modulemap
	mkdir -p $(2)/Products/usr/local/lib/$(SCHEME).framework/Modules
	echo $(MODULEMAP_TXT) > $(2)/Products/usr/local/lib/$(SCHEME).framework/Modules/module.modulemap
endef

define copy_header
	mkdir -p $(2)/Products/usr/local/lib/$(SCHEME).framework/Headers
	cp -r $(1) $(2)/Products/usr/local/lib/$(SCHEME).framework/Headers/$(SCHEME)-Swift.h
endef

all: clean build-iphoneos build-iphonesimulator build-macos create-xcframework

clean:
	rm -rf .build ./build/SwiftSyntaxWrapper.xcframework

build-iphoneos:
	xcrun xcodebuild archive \
	  -workspace . \
	  -scheme $(SCHEME) \
	  -configuration Release \
	  -destination $(DESTINATION_IOS) \
	  -derivedDataPath .build \
	  -archivePath $(ARCHIVE_PATH_IOS) \
	  SKIP_INSTALL=NO \
	  BUILD_LIBRARY_FOR_DISTRIBUTION=YES
	$(call copy_swiftmodule,$(SWIFTMODULE_SOURCE_IOS),$(ARCHIVE_PATH_IOS))
	$(call copy_header,$(SWIFTHEADER_SOURCE_IOS),$(ARCHIVE_PATH_IOS))
	$(call copy_modulemap,$(MODULEMAP_SOURCE_IOS),$(ARCHIVE_PATH_IOS))


build-iphonesimulator:
	xcrun xcodebuild archive \
	  -workspace . \
	  -scheme $(SCHEME) \
	  -configuration Release \
	  -destination $(DESTINATION_IOS_SIMULATOR) \
	  -derivedDataPath .build \
	  -archivePath $(ARCHIVE_PATH_IOS_SIMULATOR) \
	  SKIP_INSTALL=NO \
	  BUILD_LIBRARY_FOR_DISTRIBUTION=YES
	$(call copy_swiftmodule,$(SWIFTMODULE_SOURCE_IOS_SIMULATOR),$(ARCHIVE_PATH_IOS_SIMULATOR))
	$(call copy_header,$(SWIFTHEADER_SOURCE_IOS_SIMULATOR),$(ARCHIVE_PATH_IOS_SIMULATOR))
	$(call copy_modulemap,$(MODULEMAP_SOURCE_IOS_SIMULATOR),$(ARCHIVE_PATH_IOS_SIMULATOR))

build-macos:
	xcrun xcodebuild archive \
	  -workspace . \
	  -scheme $(SCHEME) \
	  -configuration Release \
	  -destination $(DESTINATION_MACOS) \
	  -derivedDataPath .build \
	  -archivePath $(ARCHIVE_PATH_MACOS) \
	  SKIP_INSTALL=NO \
	  BUILD_LIBRARY_FOR_DISTRIBUTION=YES
	$(call copy_swiftmodule,$(SWIFTMODULE_SOURCE_MACOS),$(ARCHIVE_PATH_MACOS))
	$(call copy_header,$(SWIFTHEADER_SOURCE_MACOS),$(ARCHIVE_PATH_MACOS))
	$(call copy_modulemap,$(MODULEMAP_SOURCE_MACOS),$(ARCHIVE_PATH_MACOS))

create-xcframework:
	xcodebuild -create-xcframework \
	  -framework $(FRAMEWORK_PATH_IOS) \
	  -framework $(FRAMEWORK_PATH_IOS_SIMULATOR) \
	  -framework $(FRAMEWORK_PATH_MACOS) \
	  -output $(XCFRAMEWORK_OUTPUT)
