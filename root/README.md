# System install

## Prepare the partition

Create a partition on the target.
```
Number  Start (sector)    End (sector)  Size       Code  Name
   1          264192        42207231   20.0 GiB    8307  Linux ARM32 root (/)
   3            2048          264191   128.0 MiB   8300  Linux filesystem
```

Format ext4 partition (no 64bit and no journal).
```
sudo mke2fs -t ext4 -O ^64bit,^has_journal <device>
```

## Set up `binfmt_misc` for non-ARMv7 hosts

See the [Linux kernel documentation](https://www.kernel.org/doc/Documentation/admin-guide/binfmt-misc.rst)
for more information.

### For distributions that do not have `qemu-user-static` in their packages

Download the .deb package from a Debian mirror.
```
<mirror>/debian/pool/main/q/qemu/qemu-user-static_<version>_<host_arch>.deb
```
Extract `qemu-arm-static` from the package using `ar` (like `tar`) and
`data.tar.xz` using `tar`.

Configure binfmt_misc to use the newly acquired emulator:
```
echo ':qemu-arm:M::\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00:\xff\xff\xff\xff\xff\xff\xff\x00\x00\x00\x00\x00\x00\x00\x00\x00\xfe\xff\xff\xff:/usr/bin/qemu-arm-static:CF' > /proc/sys/fs/binfmt_misc/register
```

## Set up the system

- edit files in **root/**
- create a root password in **config/.root_pwd**
- create the archive `rootfs.tar.gz` by running `make`
- mount the system partition
- extract the archive

## `hd-idle`

`hd-idle` is a small utility written by Christian Mueller to put the
drive in standby mode after a period of inactivity.
