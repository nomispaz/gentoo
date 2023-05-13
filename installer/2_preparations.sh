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
echo 'MAKEOPTS="-j8"' >> /etc/portage/make.conf

#use german mirrors
echo 'GENTOO_MIRRORS="http://ftp.agdsn.de/gentoo https://ftp.agdsn.de/gentoo rsync://ftp.agdsn.de/gentoo https://ftp.gwdg.de/pub/linux/gentoo/ http://ftp.gwdg.de/pub/linux/gentoo/ ftp://ftp.gwdg.de/pub/linux/gentoo/ rsync://ftp.gwdg.de/gentoo/ https://ftp.uni-hannover.de/gentoo/ http://ftp.uni-hannover.de/gentoo/ ftp://ftp.uni-hannover.de/gentoo/ https://packages.hs-regensburg.de/gentoo-distfiles/ http://packages.hs-regensburg.de/gentoo-distfiles/ rsync://packages.hs-regensburg.de/gentoo-distfiles/ https://linux.rz.ruhr-uni-bochum.de/download/gentoo-mirror/ http://linux.rz.ruhr-uni-bochum.de/download/gentoo-mirror/ ftp://linux.rz.ruhr-uni-bochum.de/gentoo-mirror/ rsync://linux.rz.ruhr-uni-bochum.de/gentoo https://ftp.halifax.rwth-aachen.de/gentoo/ http://ftp.halifax.rwth-aachen.de/gentoo/ ftp://ftp.halifax.rwth-aachen.de/gentoo/ rsync://ftp.halifax.rwth-aachen.de/gentoo/ https://ftp.tu-ilmenau.de/mirror/gentoo/ http://ftp.tu-ilmenau.de/mirror/gentoo/ ftp://ftp.tu-ilmenau.de/mirror/gentoo/ rsync://ftp.tu-ilmenau.de/gentoo/ https://ftp.fau.de/gentoo http://ftp.fau.de/gentoo ftp://ftp.fau.de/gentoo rsync://ftp.fau.de/gentoo https://ftp-stud.hs-esslingen.de/pub/Mirrors/gentoo/ http://ftp-stud.hs-esslingen.de/pub/Mirrors/gentoo/ ftp://ftp-stud.hs-esslingen.de/pub/Mirrors/gentoo/ rsync://ftp-stud.hs-esslingen.de/gentoo/"' >> /etc/portage/make.conf

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

cp /home/gentoo/gentoo/installer/3_chroot.sh /mnt/gentoo
echo "enter chroot environment. Next step: run 3_chroot.sh"
chroot /mnt/gentoo /bin/bash 
