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

echo "Create partition table (only do this if no partition table exists!)"
parted /dev/$installDrive mklabel gpt

lsblk -l

echo "efi partition"
parted /dev/$installDrive mkpart primary fat32 3MB 515MB
read efiDrive

echo "root partition"
parted /dev/$installDrive mkpart primary btrfs 515MB 100%
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
mount --mkdir -t btrfs -o defaults,noatime,compress=zstd,subvol=root /dev/$rootDrive /mnt/gentoo
mount --mkdir -t btrfs -o defaults,noatime,compress=zstd,subvol=home /dev/$rootDrive /mnt/gentoo/home
mount --mkdir -t btrfs -o defaults,noatime,compress=zstd,subvol=data /dev/$rootDrive /mnt/gentoo/data
mount --mkdir -t btrfs -o defaults,noatime,compress=zstd,subvol=var /dev/$rootDrive /mnt/gentoo/var
mount --mkdir -t btrfs -o defaults,noatime,compress=zstd,subvol=snapshots /dev/$rootDrive /mnt/gentoo/.snapshots

echo "mount efi"
mount --mkdir /dev/$efiDrive /mnt/gentoo/boot/efi

cd /mnt/gentoo
#wget "https://bouncer.gentoo.org/fetch/root/all/releases/amd64/autobuilds/20230611T170207Z/stage3-amd64-desktop-systemd-20230611T170207Z.tar.xz"
wget "https://distfiles.gentoo.org/releases/amd64/autobuilds/20230813T170146Z/stage3-amd64-desktop-systemd-20230813T170146Z.tar.xz"
echo "Run /home/gentoo/gentoo/install/2_preparations.sh. Never leave /mnt/gentoo!"
