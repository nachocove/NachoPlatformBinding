all:
	make -C NachoPlatformLib
	make -C NachoPlatformLib.Mac
	make -C NachoPlatformBinding

clean:
	make -C NachoPlatformLib clean
	make -C NachoPlatformLib.Mac clean
	make -C NachoPlatformBinding clean
