#!/bin/bash
#
# 1_partitions.sh
#
# Script by nomispaz
# Version 1
# Date 24.04.2023

echo "show devices"
lsblk -l

#echo "set install drive to: "
#read installDrive

#echo "Create partition table (only do this if no partition table exists!)"
#parted /dev/$installDrive mklabel gpt

#lsblk -l

#echo "efi drive"
#parted /dev/$installDrive mkpart primary fat32 3MB 515MB
#read efiDrive
efiDrive=nvme0n1p4

#echo "root drive"
#parted /dev/$installDrive mkpart primary btrfs 515MB 100%
#read rootDrive
rootDrive=nvme0n1p5

#echo "format partitions"
#mkfs.vfat -F 32 /dev/$efiDrive
#mkfs.btrfs /dev/$rootDrive

echo "mount installDrive to /mnt/gentoo"
mount -o noatime,compress=zstd /dev/$rootDrive /mnt/gentoo

echo "create subvolumes"
btrfs subvolume create /mnt/gentoo/root
btrfs subvolume create /mnt/gentoo/home
btrfs subvolume create /mnt/gentoo/data
btrfs subvolume create /mnt/gentoo/var
btrfs subvolume create /mnt/gentoo/snapshots

echo "subolume for swap-file"
btrfs subvolume create /mnt/gentoo/swap

echo "unmount installDrive"
umount /mnt/gentoo

echo "mount subvolumes"
mount --mkdir -t btrfs -o defaults,noatime,compress=zstd,subvol=root /dev/$rootDrive /mnt/gentoo
mount --mkdir -t btrfs -o defaults,noatime,compress=zstd,subvol=home /dev/$rootDrive /mnt/gentoo/home
mount --mkdir -t btrfs -o defaults,noatime,compress=zstd,subvol=data /dev/$rootDrive /mnt/gentoo/data
mount --mkdir -t btrfs -o defaults,noatime,compress=zstd,subvol=var /dev/$rootDrive /mnt/gentoo/var
mount --mkdir -t btrfs -o defaults,noatime,compress=zstd,subvol=snapshots /dev/$rootDrive /mnt/gentoo/.snapshots

echo "mount and create swap-partition and file"
mount --mkdir -o noatime,compress=zstd,subvol=swap /dev/$rootDrive /mnt/gentoo/swap
btrfs filesystem mkswapfile --size 4g --uuid clear /mnt/gentoo/swap/swapfile
swapon /mnt/gentoo/swap/swapfile

echo "mount efi"
mount --mkdir /dev/$efiDrive /mnt/gentoo/boot/efi

wget "https://distfiles.gentoo.org/releases/amd64/autobuilds/20250105T170325Z/stage3-amd64-desktop-systemd-20250105T170325Z.tar.xz" -P /mnt/gentoo/

echo "extract tarball"
tar xpvf /mnt/gentoo/stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner -C /mnt/gentoo

###############################################################
# generate make.conf
#
cat <<EOF > /mnt/gentoo/etc/portage/make.conf
# These settings were set by the catalyst build script that automatically
# built this stage.
# Please consult /usr/share/portage/config/make.conf.example for a more
# detailed example.
COMMON_FLAGS="-O2 -pipe -march=native"
CFLAGS="${COMMON_FLAGS}"
CXXFLAGS="${COMMON_FLAGS}"
FCFLAGS="${COMMON_FLAGS}"
FFLAGS="${COMMON_FLAGS}"
RUSTFLAGS="${RUSTFLAGS} -C target-cpu=native"

# NOTE: This stage was built with the bindist Use flag enabled

# This sets the language of build output to English.
# Please keep this setting intact when reporting bugs.
LC_MESSAGES=C.utf8
GENTOO_MIRRORS="https://ftp.halifax.rwth-aachen.de/gentoo/ http://ftp.halifax.rwth-aachen.de/gentoo/ ftp://ftp.halifax.rwth-aachen.de/gentoo/ rsync://ftp.halifax.rwth-aachen.de/gentoo/"

USE=""
MAKEOPTS="--jobs 14 --load-average 15"
ACCEPT_LICENSE="@FREE @GPL-COMPATIBLE @BINARY-REDISTRIBUTABLE"
GRUB_PLATFORMS="efi-64"
VIDEO_CARDS="amdgpu radeonsi radeon nvidia nouveau intel"
FEATURES="${FEATURES} binpkg-request-signature"
GRUB_PLATFORMS="efi-64"
EOF

echo "copy current dns info"
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/

cp 02_chroot.sh /mnt/gentoo/
cp 03_chroot_install_system.sh /mnt/gentoo/

echo "enter chroot environment. Next step: run 02_chroot.sh"
arch-chroot /mnt/gentoo
