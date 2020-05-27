#!/bin/sh

apk update
apk add alpine-baselayout build-base busybox-initscripts \
        cryptsetup lvm2 openrc openssh-server util-linux

# Agetty
ln -sf /etc/init.d/agetty /etc/init.d/agetty.console
ln -sf /etc/conf.d/agetty /etc/conf.d/agetty.console

# hd-idle
gcc /usr/src/hd-idle.c -o /usr/sbin/hd-idle

rc-update add devfs sysinit

rc-update add bootmisc sysinit
rc-update add hostname sysinit
rc-update add networking sysinit
rc-update add ntpd sysinit
rc-update add sysctl sysinit
rc-update add syslog sysinit

rc-update add agetty.console default
rc-update add hd-idle default
rc-update add sshd default

rc-update add killprocs shutdown
rc-update add mount-ro shutdown
rc-update add savecache shutdown

echo "root:$(cat /tmp/config/.root_pwd)" | chpasswd
