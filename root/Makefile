MIRROR=http://dl-cdn.alpinelinux.org/alpine

ALPINE_MAJ_V=3.11
ALPINE_MIN_V=3.11.6

.PHONY: all clean rootfs

all: rootfs.tar.gz

clean:
	rm -f rootfs.tar.gz
	rm -rf rootfs
	rm -f minirootfs.tar

rootfs.tar.gz: minirootfs.tar
	# Update minirootfs with configuration files
	tar -rf minirootfs.tar -C root etc root sbin usr
	# Extract minirootfs
	mkdir -p rootfs
	tar -xf minirootfs.tar -C rootfs
	# Further configure the system
	docker run -v $(realpath rootfs):/mnt -v $(realpath config):/mnt/tmp/config alpine chroot /mnt /tmp/config/configure.sh
	# Create archive
	tar --create --gz --owner root --group root --file $@ -C rootfs .

minirootfs.tar:
	wget $(MIRROR)/v3.11/releases/armhf/alpine-minirootfs-3.11.6-armhf.tar.gz -O $@.gz
	gzip -d $@.gz
