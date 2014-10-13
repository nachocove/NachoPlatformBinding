
XBUILD=xcodebuild
PROJECT_ROOT=.
PROJECT=$(PROJECT_ROOT)/NachoPlatformLib.xcodeproj
TARGET=NachoPlatformLib

.PHONY: libNachoPlatformLib-i386.a libNachoPlatformLib-armv7.a

all: libNachoPlatformLibSDK.a

libNachoPlatformLib-i386.a:
	$(XBUILD) -project $(PROJECT) -target $(TARGET) -sdk iphonesimulator -configuration Release clean build
	mv -f $(PROJECT_ROOT)/build/Release-iphonesimulator/lib$(TARGET).a $@

libNachoPlatformLib-armv7.a:
	$(XBUILD) -project $(PROJECT) -target $(TARGET) -sdk iphoneos -arch armv7 -configuration Release clean build
	mv -f $(PROJECT_ROOT)/build/Release-iphoneos/lib$(TARGET).a $@

libNachoPlatformLibSDK.a: libNachoPlatformLib-i386.a libNachoPlatformLib-armv7.a
	lipo -create -output $@ $^

clean:
	rm -fr build
	rm -f *.a *.dll
	rm -fr ./NachoPlatformLib.xcodeproj/project.xcworkspace
	rm -fr ./NachoPlatformLib.xcodeproj/xcuserdata

