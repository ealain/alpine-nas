MIRROR=http://dl-cdn.alpinelinux.org/alpine

ALPINE_MAJ_V=3.11
ALPINE_MIN_V=3.11.6

.PHONY: all clean rootfs

all: rootfs.tar.gz

clean:
	rm -f rootfs.tar.gz
	rm -rf rootfs
	rm -f minirootfs.tar

rootfs.tar.gz: rootfs
	# Create archive
	tar --create --gz --owner root --group root --file $@ -C rootfs .

rootfs: minirootfs.tar \
		ovl/etc/apk/repositories \
		ovl/etc/hostname \
		ovl/etc/init.d/hd-idle \
		ovl/etc/inittab \
		ovl/etc/motd \
		ovl/etc/network/interfaces \
		ovl/etc/resolv.conf \
		ovl/etc/sysctl.conf \
		ovl/root/.ssh/authorized_keys \
		ovl/usr/src/hd-idle.c
	mkdir -p rootfs
	# Update minirootfs with configuration files
	echo $(filter ovl/%, $?)
	$(foreach f, $(filter ovl/%, $?), tar -rf minirootfs.tar -C ovl $(patsubst ovl/%, %, $f);)
	# Extract minirootfs
	tar -xf minirootfs.tar -C rootfs
	# Further configure the system
	docker run -v $(realpath rootfs):/mnt -v $(realpath config):/mnt/tmp/config alpine chroot /mnt /tmp/config/configure.sh

minirootfs.tar:
	wget $(MIRROR)/v3.11/releases/armhf/alpine-minirootfs-3.11.6-armhf.tar.gz -O $@.gz
	gzip -d $@.gz
