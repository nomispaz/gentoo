#!/bin/bash
#
# 1_partitions.sh
#
# Script by nomispaz
# Version 1
# Date 24.04.2023

echo "show devices"
lsblk -l

echo "set install drive to: "
read installDrive

echo "efi partition"
parted /dev/$installDrive mkpart primary fat32 3MB 515MB
efiDrive=$installDrive"1"

echo "swap partition"
parted /dev/$installDrive mkpart primary linux-swap 515MB 2563MB
swapDrive=$installDrive"2"

echo "root partition"
parted /dev/$installDrive mkpart primary btrfs 2563MB 100%
rootDrive=$installDrive"3"

echo "format partitions"
mkfs.vfat -F 32 /dev/$efiDrive
mkswap /dev/$swapDrive
mkfs.btrfs /dev/$rootDrive

echo "mount installDrive to /mnt"
mount -o noatime,compress=zstd /dev/$rootDrive /mnt

echo "create subvolumes"
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/data
btrfs subvolume create /mnt/snapshots
btrfs subvolume create /mnt/var_log
btrfs subvolume create /mnt/var_cache

echo "unmount installDrive"
umount /mnt

echo "mount root partition"
mount --mkdir -o noatime,compress=zstd,subvol=root /dev/$rootDrive /mnt/gentoo
swapon /dev/$swapDrive

cd /mnt/gentoo
echo "next step: get wget stage_3 tarball"
