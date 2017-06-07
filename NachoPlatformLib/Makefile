
XBUILD=xcodebuild
PROJECT_ROOT=.
TOP:=../..
PROJECT=$(PROJECT_ROOT)/NachoPlatformLib.xcodeproj
TARGET=NachoPlatformLib
LIBCRYPTO:=$(TOP)/ios-openssl/lib/libcrypto.a

.PHONY: libNachoPlatformLib-i386.a libNachoPlatformLib-armv7.a

all: build libNachoPlatformLibSDK.a

build:
	mkdir -p build

$(LIBCRYPTO):
	make -C $(TOP)/ios-openssl

libNachoPlatformLib-i386.a: $(LIBCRYPTO)
	$(XBUILD) -project $(PROJECT) -target $(TARGET) -sdk iphonesimulator -arch i386 -configuration Release build
	mv -f $(PROJECT_ROOT)/build/Release-iphonesimulator/lib$(TARGET).a $@

libNachoPlatformLib-x86_64.a: $(LIBCRYPTO)
	$(XBUILD) -project $(PROJECT) -target $(TARGET) -sdk iphonesimulator -arch x86_64 -configuration Release build TARGET_BUILD_DIR='./build/build-x86_64'
	mv -f ./build/build-x86_64/lib$(TARGET).a $@

libNachoPlatformLib-armv7.a: $(LIBCRYPTO)
	$(XBUILD) -project $(PROJECT) -target $(TARGET) -sdk iphoneos -arch armv7 -configuration Release build
	mv -f $(PROJECT_ROOT)/build/Release-iphoneos/lib$(TARGET).a $@

libNachoPlatformLib-arm64.a: $(LIBCRYPTO)
	$(XBUILD) -project $(PROJECT) -target $(TARGET) -sdk iphoneos -arch arm64 -configuration Release build TARGET_BUILD_DIR='./build/build-arm64'
	mv -f ./build/build-arm64/lib$(TARGET).a $@

libNachoPlatformLibSDK.a: libNachoPlatformLib-i386.a libNachoPlatformLib-armv7.a libNachoPlatformLib-arm64.a libNachoPlatformLib-x86_64.a
	lipo -create -output $@ $^

clean:
	$(XBUILD) -project $(PROJECT) -target $(TARGET) -sdk iphonesimulator -arch i386 -configuration Release clean
	$(XBUILD) -project $(PROJECT) -target $(TARGET) -sdk iphonesimulator -arch x86_64 -configuration Release clean TARGET_BUILD_DIR='./build/build-x86_64'
	$(XBUILD) -project $(PROJECT) -target $(TARGET) -sdk iphoneos -arch armv7 -configuration Release clean
	$(XBUILD) -project $(PROJECT) -target $(TARGET) -sdk iphoneos -arch arm64 -configuration Release clean TARGET_BUILD_DIR='./build/build-arm64'
	rm -fr build
	rm -f *.a *.dll
	make -C $(TOP)/ios-openssl clean

