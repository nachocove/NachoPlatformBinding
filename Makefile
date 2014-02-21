all:
	make -C NachoPlatformLib
	make -C NachoPlatformBinding

clean:
	make -C NachoPlatformLib clean
	make -C NachoPlatformBinding clean
