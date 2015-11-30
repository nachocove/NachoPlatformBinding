
XBUILD=xcodebuild
PROJECT_ROOT=.
TOP:=../..
PROJECT=$(PROJECT_ROOT)/NachoPlatformLib.xcodeproj
TARGET=NachoPlatformLib

.PHONY: libNachoPlatformLib-i386.a libNachoPlatformLib-armv7.a

all: build libNachoPlatformLibSDK.a

build:
	mkdir -p build

libNachoPlatformLib-i386.a:
	$(XBUILD) -project $(PROJECT) -target $(TARGET) -sdk iphonesimulator -arch i386 -configuration Release clean build
	mv -f $(PROJECT_ROOT)/build/Release-iphonesimulator/lib$(TARGET).a $@

libNachoPlatformLib-x86_64.a:
	$(XBUILD) -project $(PROJECT) -target $(TARGET) -sdk iphonesimulator -arch x86_64 -configuration Release clean build TARGET_BUILD_DIR='./build/build-x86_64'
	mv -f ./build/build-x86_64/lib$(TARGET).a $@

libNachoPlatformLib-armv7.a:
	$(XBUILD) -project $(PROJECT) -target $(TARGET) -sdk iphoneos -arch armv7 -configuration Release clean build
	mv -f $(PROJECT_ROOT)/build/Release-iphoneos/lib$(TARGET).a $@

libNachoPlatformLib-arm64.a:
	$(XBUILD) -project $(PROJECT) -target $(TARGET) -sdk iphoneos -arch arm64 -configuration Release clean build TARGET_BUILD_DIR='./build/build-arm64'
	mv -f ./build/build-arm64/lib$(TARGET).a $@

libNachoPlatformLibSDK.a: libNachoPlatformLib-i386.a libNachoPlatformLib-armv7.a libNachoPlatformLib-arm64.a libNachoPlatformLib-x86_64.a
	lipo -create -output $@ $^

clean:
	rm -fr build
	rm -f *.a *.dll
	rm -fr ./NachoPlatformLib.xcodeproj/project.xcworkspace
	rm -fr ./NachoPlatformLib.xcodeproj/xcuserdata

