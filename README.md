# Install Alpine Linux on WD My Cloud NAS

*Device reference: [WDBCTL0030HWT-EESN](https://documents.westerndigital.com/content/dam/doc-library/en_gb/assets/public/wd/product/external-storage/my_cloud/my-cloud/mycloud-product-overview.pdf)*

## Device components

Board reference: `WD_Glacier_DB-88F6720-V2`
- Marvell SoC [Armada 375 (88F6720)](https://www.marvell.com/content/dam/marvell/en/public-collateral/embedded-processors/marvell-embedded-processors-armada-375-product-brief-2013-05.pdf)
- Macronix flash memory: [MX25L8006E](https://www.macronix.com/Lists/Datasheet/Attachments/7578/MX25L8006E,%203V,%208Mb,%20v1.2.pdf)
- Samsung DDR3 SDRAM: 1x 512 MB [K4B4G1646D-BCK0](https://www.samsung.com/semiconductor/global.semi/file/resource/2017/11/DS_K4B4G1646D-BC-I_Rev103-0.pdf)
- Western Digital hard drive: [WD30EFRX](https://documents.westerndigital.com/content/dam/doc-library/en_us/assets/public/western-digital/product/internal-drives/wd-red-hdd/data-sheet-western-digital-wd-red-hdd-2879-800002.pdf).


## Disclaimer

**I am not responsible for any damage or waranty loss. This is not supported
by Western Digital.**

Instructions lead to data loss. Consider backing up data. Think twice before
running scripts.


## Big picture

1. Trial and error show that the bootloader looks for two files on partition 3
(and then partition 5 if the first startup fails):
- uImage (kernel and dtb files),
- uRamdisk (compressed ramdisk).
2. `/linuxrc` (initrd) is executed, `/bin/busybox` takes over, reads `/etc/inittab` and
executes `/etc/rc.sh`,
3. special filesystems are mounted and `scripts/system_init` from `image.cfs`
is run.

For more, see [partitions](partitions.md).


## Alpine Linux installation

### Dependencies

- `mkimage` from [U-Boot](https://www.denx.de/wiki/U-Boot/WebHome) ([uboot-tools](https://www.archlinux.org/packages/community/x86_64/uboot-tools/))
- `arm-none-eabi-gcc` from ARM ([gcc-arm-none-eabi-bin](https://aur.archlinux.org/packages/gcc-arm-none-eabi-bin/))

### Configure the boot partition

1. Create an ext2 partition with number 3 (U-Boot looks in 3 and then 5)
```
Number  Start (sector)    End (sector)   Size      Code  Name
   3            2048          264191   128.0 MiB   8300  Linux filesystem
```

```
mke2fs -t ext2 -m 0 <device>
```
2. Generate `uImage` and `uRamdisk` (optionally edit the kernel configuration in `config` and the `init` script for initramfs)
```
make
```
3. Copy the files to the folder `/boot`
```
mount /dev/sdb3 /mnt
cp uImage /mnt/boot/
cp uRamdisk /mnt/boot/
umount /mnt
```
4. Boot the device

### Install the system

Instructions in **root/README.md**.


## Debugging tools

- SATA to USB adapter (partition and write to the hard drive)
- UART to USB adapter and soldering material for a U-Boot prompt


## Next steps

- lock the root account
- configure the partition to save data
- set up rsync


## Caveats

- the hard drive does not automatically go to standby mode


## Credits
- [Fox's website](https://fox-exe.ru/WDMyCloud/WDMyCloud-Gen2/)
- [Doozan forum](https://forum.doozan.com/read.php?2,32146)
- [John-Q's wdmc-gen2 repository @GitHub (and its forks)](https://github.com/Johns-Q/wdmc-gen2)
