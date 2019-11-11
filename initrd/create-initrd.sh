#!/bin/sh

# Copyright (C) 2019 ealain
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.


BUSYBOX_URL=https://busybox.net/downloads/binaries/1.31.0-defconfig-multiarch-musl/busybox-armv7l
MUSL_URL=http://dl-cdn.alpinelinux.org/alpine/v3.10/main/armhf/musl-1.1.22-r3.apk

# Perform some checks
[ -d initrd_mnt ] && echo 'Please remove the directory initrd_mnt' && exit 0
[ -f initrd ] && echo 'Please remove the file initrd' && exit 0
if losetup -a | grep loop0; then
    echo 'Please detach loop0'
    exit 0
fi

# Create directory to be used as a mount point
mkdir initrd_mnt

# Create a device for the loopback
dd if=/dev/zero of=initrd bs=512 count=$((2**14))

# Create the loopback device
losetup loop0 initrd

# Create an ext2 filesystem without reserved blocks
mke2fs -t ext2 -m 0 /dev/loop0

# Mount the filesystem
mount /dev/loop0 initrd_mnt

# Install musl
wget $MUSL_URL -O musl.tar.gz
tar xvf musl.tar.gz -C initrd_mnt lib/ld-musl-armhf.so.1
chmod 755 initrd_mnt/lib/ld-musl-armhf.so.1

# Install Busybox
mkdir initrd_mnt/bin
wget $BUSYBOX_URL -O initrd_mnt/bin/busybox
chmod 755 initrd_mnt/bin/busybox

mkdir initrd_mnt/proc
mkdir initrd_mnt/dev
mkdir initrd_mnt/sbin
cp init initrd_mnt/sbin

# Unmount the filesystem
umount initrd_mnt
losetup -D loop0

# Create uRamdisk
gzip initrd
mkimage -A arm -T ramdisk -C gzip -d initrd.gz uRamdisk

# Cleanup
rm -r initrd_mnt
rm initrd.gz
rm musl.tar.gz
