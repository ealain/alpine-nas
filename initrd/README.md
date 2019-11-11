# Boot partition

Reminder: U-Boot looks for `uImage` and `uRamdisk` in partition 3 [and 5].

## Create an ext2 partition
```
Number  Start (sector)    End (sector)   Size      Code  Name
   3            2048          264191   128.0 MiB   8300  Linux filesystem
```

```
mke2fs -t ext2 -m 0 <device>
```

```
mkdir <mount_point>/boot
```

## `uImage`

Move the original `uImage` to `<mount_point>/boot`.

*Note:
- 3.10 kernel without config.gz,
- dtb files*


## `uRamdisk`

[Guide](https://www.kernel.org/doc/html/latest/admin-guide/initrd.html) on initrd.

Edit ROOT in `init` script. The number must correspond to the root partition
(see [install](/root/README.md)).

Run `create-initrd.sh`.

Move `uRamdisk` to `<mount_point>/boot`.

`uRamdisk` hierarchy:
```
uRamdisk/
├── bin
│   └── busybox
├── dev
├── lib
│   └── ld-musl-armhf.so.1
├── lost+found
├── proc
└── sbin
    └── init
```
