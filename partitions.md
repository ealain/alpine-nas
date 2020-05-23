# Original drive partitions

Partitions (3 TB):
```
Number  Start (sector)    End (sector)  Size       Code  Name
   1            2048         4196351   2.0 GiB     8200  Linux swap
   2        16779264      5860533134   2.7 TiB     0700  Microsoft basic data
   3        14682112        16779263   1024.0 MiB  0700  Microsoft basic data
   4         4196352         6293503   1024.0 MiB  0700  Microsoft basic data
   5         6293504         8390655   1024.0 MiB  0700  Microsoft basic data
   6         8390656        12584959   2.0 GiB     0700  Microsoft basic data
   7        12584960        14682111   1024.0 MiB  0700  Microsoft basic data
```

## Partition 1
- swap space

## Partition 2
- ext4
- users' files

## Partition 3
- ext4
- boot partition
```
└── boot
    ├── image.cfs
    ├── image.cfs.sep
    ├── uImage
    └── uRamdisk
```

To list the information contained in the header of an U-Boot image:
```
mkimage -l uRamdisk
```
`mkimage` is available from the package `uboot-tools` (Alpine) or `u-boot-tools`
(Ubuntu).

To strip the header:
```
dd if=uImage bs=64 skip=1 of=Image
```

### uImage

`uImage` is a U-Boot image with the kernel and dtb (device tree binary) files.

Use [extract-dtb](https://github.com/PabloCastellano/extract-dtb) after
stripping the header.

### uRamdisk

`uRamdisk` is a U-Boot Image with the RAMDisk.

To see the content of `uRamdisk`:
```
dd if=uRamdisk bs=64 skip=1 of=ramdisk.gz
gzip -d ramdisk.gz
mount -o loop ramdisk <mount_point>
```

### image.cfs

```
dd if=image.cfs of=image.sqsh skip=4 bs=512
mount -t squashfs -o loop /mnt
```

The filesystem contains many different files and is mounted on `/usr/local/modules`.

## Partition 4
- ext4
```
├── .@database@
│   └── mysql
├── .systemfile
│   ├── P2
│   └── schedcfgs
└── .wdphotos
```

## Partition 5
- ext4
- boot partition (rescue)
```
└── boot
    ├── rescue_firmware
    ├── rescue_fw_version.txt
    ├── uImage
    └── uRamdisk
```

## Partition 6
- ext4
- empty

## Partition 7
- ext4
- configuration files
- mounted on `/usr/local/config`
