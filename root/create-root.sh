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


MIRROR=http://dl-cdn.alpinelinux.org/alpine
MOUNT_POINT=/mnt

ALPINE_MAJ_V=3.10
ALPINE_MIN_V=3.10.3


# Download a release of Alpine Linux (minirootfs flavor)
wget $MIRROR/v$ALPINE_MAJ_V/releases/armhf/alpine-minirootfs-$ALPINE_MIN_V-armhf.tar.gz

# Uncompress the archive to add custom files
gzip -d alpine-minirootfs-$ALPINE_MIN_V-armhf.tar.gz

# Add custom files
tar -rf alpine-minirootfs-$ALPINE_MIN_V-armhf.tar -C root etc root

# Extract the files in the archive to the mount point
tar -xf alpine-minirootfs-$ALPINE_MIN_V-armhf.tar -C $MOUNT_POINT

# Remove the archive
rm alpine-minirootfs-$ALPINE_MIN_V-armhf.tar

# Use docker to run commands in chroot
DOCKER_CHROOT="docker run -v $(realpath $MOUNT_POINT):/mnt alpine chroot /mnt"

$DOCKER_CHROOT apk update
$DOCKER_CHROOT apk add alpine-base openssh-server

for initscript in devfs dmesg hwdrivers; do
    $DOCKER_CHROOT ln -sf /etc/init.d/$initscript /etc/runlevels/sysinit/$initscript
done

for initscript in bootmisc hostname hwclock modules networking swap sysctl syslog; do
    $DOCKER_CHROOT ln -sf /etc/init.d/$initscript /etc/runlevels/boot/$initscript
done

for initscript in sshd; do
    $DOCKER_CHROOT ln -sf /etc/init.d/$initscript /etc/runlevels/default/$initscript
done

for initscript in killprocs mount-ro savecache; do
    $DOCKER_CHROOT ln -sf /etc/init.d/$initscript /etc/runlevels/shutdown/$initscript
done

# Unlock the root account (login with key)
$DOCKER_CHROOT sed -i 's_root:!_root:*_' /etc/shadow
