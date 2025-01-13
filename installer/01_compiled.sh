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

#echo "Create partition table (only do this if no partition table exists!)"
#parted /dev/$installDrive mklabel gpt

lsblk -l

#echo "efi drive"
#parted /dev/$installDrive mkpart primary fat32 3MB 515MB
#read efiDrive

#echo "root drive"
#parted /dev/$installDrive mkpart primary btrfs 515MB 100%
#read rootDrive

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

echo "subolume for swap-file"
btrfs subvolume create /mnt/swap

echo "unmount installDrive"
umount /mnt

echo "mount subvolumes"
mount --mkdir -t btrfs -o defaults,noatime,compress=zstd,subvol=root /dev/$rootDrive /mnt
mount --mkdir -t btrfs -o defaults,noatime,compress=zstd,subvol=home /dev/$rootDrive /mnt/home
mount --mkdir -t btrfs -o defaults,noatime,compress=zstd,subvol=data /dev/$rootDrive /mnt/data
mount --mkdir -t btrfs -o defaults,noatime,compress=zstd,subvol=var /dev/$rootDrive /mnt/var
mount --mkdir -t btrfs -o defaults,noatime,compress=zstd,subvol=snapshots /dev/$rootDrive /mnt/.snapshots

echo "mount and create swap-partition and file"
mount --mkdir -o noatime,compress=zstd,subvol=swap /dev/$rootDrive /mnt/swap
btrfs filesystem mkswapfile --size 4g --uuid clear /mnt/swap/swapfile
swapon /mnt/swap/swapfile

echo "mount efi"
mount --mkdir /dev/$efiDrive /mnt/boot/efi

wget "https://distfiles.gentoo.org/releases/amd64/autobuilds/20250105T170325Z/stage3-amd64-desktop-systemd-20250105T170325Z.tar.xz" -P /mnt/

echo "extract tarball"
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner -C /mnt

###############################################################
# generate make.conf
#
cat <<EOF > /mnt/etc/portage/package.accept_keywords/packages
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
VIDEO_CARDS="amdgpu radeonsi radeon nvidia"
FEATURES="${FEATURES} binpkg-request-signature"
GRUB_PLATFORMS="efi-64"
EOF

echo "copy current dns info"
cp --dereference /etc/resolv.conf /mnt/etc/

cp /home/gentoo/gentoo/installer/02_chroot.sh /mnt/
echo "enter chroot environment. Next step: run 02_chroot.sh"
arch-chroot /mnt
