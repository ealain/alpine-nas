VERSION=5.8.9
BUSYBOX_URL=https://busybox.net/downloads/binaries/1.31.0-defconfig-multiarch-musl/busybox-armv7l
MUSL_URL=http://dl-cdn.alpinelinux.org/alpine/v3.12/main/armhf/musl-1.1.24-r9.apk
KERNEL_URL=https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-$(VERSION).tar.xz

.PHONY: all clean
all: uImage uRamdisk

clean:
	rm -f busybox-armv7l
	rm -f musl.apk
	rm -f linux-$(VERSION).tar.xz
	rm -f rd rd.gz
	rm -f zImage_and_dtb
	rm -rf initramfs
	$(MAKE) -C linux-$(VERSION) clean

uImage: zImage_and_dtb
	mkimage -A arm -O linux -T kernel -C none -a 0x00008000 -e 0x00008000 -n 'Linux $(VERSION)' -d zImage_and_dtb uImage

uRamdisk:
	touch rd
	gzip rd
	mkimage -A arm -T ramdisk -C gzip -d rd.gz uRamdisk

zImage_and_dtb: linux-$(VERSION)/arch/arm/boot/zImage \
	            linux-$(VERSION)/arch/arm/boot/dts/armada-375-wdmc-gen2.dtb
	cat linux-$(VERSION)/arch/arm/boot/zImage linux-$(VERSION)/arch/arm/boot/dts/armada-375-wdmc-gen2.dtb > zImage_and_dtb

linux-$(VERSION)/arch/arm/boot/dts/armada-375-wdmc-gen2.dtb: linux-$(VERSION)/arch/arm/boot/dts/armada-375-wdmc-gen2.dts
	ARCH=arm CROSS_COMPILE=arm-none-eabi- $(MAKE) -C linux-$(VERSION) armada-375-wdmc-gen2.dtb

linux-$(VERSION)/arch/arm/boot/dts/armada-375-wdmc-gen2.dts:
	cp $(@F) $@

linux-$(VERSION)/arch/arm/boot/zImage: linux-$(VERSION)/.config \
                                       linux-$(VERSION)/initramfs.cpio
	ARCH=arm CROSS_COMPILE=arm-none-eabi- $(MAKE) -C linux-$(VERSION) -j 4 zImage

linux-$(VERSION)/.config: linux-$(VERSION).tar.xz config
	tar -x -f linux-$(VERSION).tar.xz
	cp config linux-$(VERSION)/.config

linux-$(VERSION)/initramfs.cpio: initramfs/init \
	                             initramfs/bin/busybox \
	                             initramfs/dev/console \
								 initramfs/lib/ld-musl-armhf.so.1 \
	                             initramfs/proc
	cd initramfs && find . -print0 | cpio --null --create --dereference --format=newc -F ../$@

initramfs/init: init
	mkdir -p initramfs
	cp init $@

initramfs/bin/busybox: busybox-armv7l
	mkdir -p initramfs/{bin,sbin,usr/bin,usr/sbin}
	cp $< $@
	chmod 755 $@

initramfs/dev/console:
	mkdir -p $(@D)
	ln -s /dev/console $@
	
initramfs/lib/ld-musl-armhf.so.1: musl.apk
	mkdir -p $(@D)
	tar -x -m -f $< -C initramfs

initramfs/proc:
	mkdir -p $@

busybox-armv7l:
	curl $(BUSYBOX_URL) -o $@

linux-$(VERSION).tar.xz:
	curl $(KERNEL_URL) -o $@

musl.apk:
	curl $(MUSL_URL) -o $@
