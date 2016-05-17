
XBUILD=xcodebuild
PROJECT_ROOT=.
TOP:=../..
PROJECT=$(PROJECT_ROOT)/NachoPlatformLib.xcodeproj
TARGET=NachoPlatformLib
LIBCRYPTO:=$(TOP)/ios-openssl/lib/libcrypto.a

all: build libNachoPlatformLibSDK.a

build:
	mkdir -p build

$(LIBCRYPTO):
	make -C $(TOP)/ios-openssl

libNachoPlatformLib-x86_64.a: $(LIBCRYPTO)
	$(XBUILD) -project $(PROJECT) -target $(TARGET) -sdk macosx -arch x86_64 -configuration Release clean build TARGET_BUILD_DIR='./build/build-x86_64'
	mv -f ./build/build-x86_64/lib$(TARGET).a $@

libNachoPlatformLibSDK.a: libNachoPlatformLib-x86_64.a
	lipo -create -output $@ $^

clean:
	rm -fr build
	rm -f *.a *.dll
	rm -fr ./NachoPlatformLib.xcodeproj/project.xcworkspace
	rm -fr ./NachoPlatformLib.xcodeproj/xcuserdata

