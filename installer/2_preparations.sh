#!/bin/bash
#
# 1_preperations.sh
#
# Script by nomispaz
# Version 1
# Date 24.04.2023

echo "extract tarball"
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner

#current stage: set compile options. Use standard settings for now
#nano -w /mnt/gentoo/etc/portage/make.conf
echo "set makeopts to threads in VM"
echo 'MAKEOPTS="-j4"' >> /etc/portage/make.conf

echo "select download mirrors"
mirrorselect -i -o >> /mnt/gentoo/etc/portage/make.conf

echo "generate ebase reporitory"
mkdir --parents /mnt/gentoo/etc/portage/repos.conf
cp /mnt/gentoo/usr/share/portage/config/repos.conf /mnt/gentoo/etc/portage/repos.conf/gentoo.conf

echo "copy current dns info"
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/

echo "mount necessary file systems"
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
mount --bind /run /mnt/gentoo/run
mount --make-slave /mnt/gentoo/run 

echo "enter chroot environment"
chroot /mnt/gentoo /bin/bash 
