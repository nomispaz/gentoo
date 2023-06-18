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
#parted /dev/$installDrive mkpart primary fat32 3MB 515MB
read efiDrive

echo "root partition"
#parted /dev/$installDrive mkpart primary btrfs 2563MB 100%
read rootDrive

#echo "format partitions"
#mkfs.vfat -F 32 /dev/$efiDrive
#mkfs.btrfs /dev/$rootDrive

echo "mount installDrive to /mnt"
mount -o noatime,compress=zstd /dev/$rootDrive /mnt

echo "create subvolumes"
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/data
btrfs subvolume create /mnt/var
btrfs subvolume create /mnt/snapshots

echo "unmount installDrive"
umount /mnt

echo "mount subvolumes"
mount --mkdir -o noatime,compress=zstd,subvol=root /dev/$rootDrive /mnt/gentoo
mount --mkdir -o noatime,compress=zstd,subvol=home /dev/$rootDrive /mnt/gentoo/home
mount --mkdir -o noatime,compress=zstd,subvol=data /dev/$rootDrive /mnt/gentoo/data
mount --mkdir -o noatime,compress=zstd,subvol=var /dev/$rootDrive /mnt/gentoo/var
mount --mkdir -o noatime,compress=zstd,subvol=snapshots /dev/$rootDrive /mnt/gentoo/.snapshots

echo "mount efi"
mount --mkdir /dev/$efiDrive /mnt/gentoo/boot/efi

cd /mnt/gentoo
wget "https://bouncer.gentoo.org/fetch/root/all/releases/amd64/autobuilds/20230611T170207Z/stage3-amd64-desktop-systemd-20230611T170207Z.tar.xz"
echo "Run /home/gentoo/gentoo/install/2_preparations.sh. Never leave /mnt/gentoo!"
