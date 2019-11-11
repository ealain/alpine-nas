# Install Alpine Linux on WD My Cloud NAS

*Device reference: [WDBCTL0030HWT-EESN](https://documents.westerndigital.com/content/dam/doc-library/en_gb/assets/public/wd/product/external-storage/my_cloud/my-cloud/mycloud-product-overview.pdf)*

## Disclaimer

**I am not responsible for any damage or waranty loss. This is not supported
by Western Digital.**

Instructions lead to data loss. Consider backing up data. Think twice before
running scripts.

## Repository

- **initrd/**: minimal RAMDisk,
- **root/**: root filesystem based on Alpine Linux's *minirootfs*.

## Device overview

Main elements:
- board with SoC [Marvell ARMADA 375 (88F6720)](https://www.marvell.com/documents/xhvwfczzcqkjbmhbmvnb/),
- hard drive [WD30EFRX](https://documents.westerndigital.com/content/dam/doc-library/en_us/assets/public/western-digital/product/internal-drives/wd-red-hdd/data-sheet-western-digital-wd-red-hdd-2879-800002.pdf).

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

### Partition 1
- swap space

### Partition 2
- ext4
- users' files

### Partition 3
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

#### uImage

`uImage` is a U-Boot image with the kernel and dtb (device tree binary) files.

Use [extract-dtb](https://github.com/PabloCastellano/extract-dtb) after
stripping the header.

#### uRamdisk

`uRamdisk` is a U-Boot Image with the RAMDisk.

To see the content of `uRamdisk`:
```
dd if=uRamdisk bs=64 skip=1 of=ramdisk.gz
gzip -d ramdisk.gz
mount -o loop ramdisk <mount_point>
```

#### image.cfs

```
dd if=image.cfs of=image.sqsh skip=4 bs=512
mount -t squashfs -o loop /mnt
```

The filesystem contains many different files and is mounted on `/usr/local/modules`.

### Partition 4
- ext4
```
├── .@database@
│   └── mysql
├── .systemfile
│   ├── P2
│   └── schedcfgs
└── .wdphotos
```

#### Partition 5
- ext4
- boot partition (rescue)
```
└── boot
    ├── rescue_firmware
    ├── rescue_fw_version.txt
    ├── uImage
    └── uRamdisk
```

#### Partition 6
- ext4
- empty

#### Partition 7
- ext4
- configuration files
- mounted on `/usr/local/config`


### Big picture

1. Trial and error show that the bootloader looks for two files on partition 3
(and then partition 5 if the first startup fails):
- uImage (kernel and dtb files),
- uRamdisk (compressed ramdisk).
2. `/linuxrc` (initrd) is executed, `/bin/busybox` takes over, reads `/etc/inittab` and
executes `/etc/rc.sh`,
3. special filesystems are mounted and `scripts/system_init` from `image.cfs`
is run.


## Alpine Linux install

### Configure the boot partition

Instructions in **initrd/README.md**.

### Install the system

Instructions in **root/README.md**.


## Notes

- `umount -a /mnt` in init ? (/dev might prevent unmounting)


## To go further

- lock root account
- install ntpd
- set up rsync
- lvm partition (data, luks, swap)
- compile new kernel and append dtb files


## Caveats

- led is blinking
- hd is always spinning (prevent the OS from keeping files open on the drive ?)
