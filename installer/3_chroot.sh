echo "if anything happens, it should be able to continue from here"
source /etc/profile
export PS1="(chroot) ${PS1}"

echo "mount boot partition"
mount --mkdir /dev/vda1 /boot/efi

echo "choose install profile"
eselect profile list

echo "update ebuild repo"
emerge --sync

#currently no checkup of installation profiles. default for the stage-tarball is used"
# eselect profile list
# eselect profile set xxx

echo "update @world set so that updates and new use-flags can be used"
emerge --ask --verbose --update --deep --newuse @world

echo "adding first use-flags"
echo 'USE=initramfs redistributable' >> /etc/portage/make.conf

echo "set CPU_FLAGS"
emerge --ask app-portage/cpuid2cpuflags
echo "*/* $(cpuid2cpuflags)" > /etc/portage/package.use/00cpu-flags

echo "add licenses to make.conf"
echo 'ACCEPT_LICENSE="@FREE @GPL-COMPATIBLE @BINARY-REDISTRIBUTABLE"' >> /etc/portage/make.conf

echo "set locales and time"
ln -sf ../usr/share/zoneinfo/Europe/Berlin /etc/localtime

echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen
echo "KEYMAP=de-latin1" >> /etc/vconsole.conf
echo "XMGneo15Arch" >> /etc/hostname
locale-gen

echo "reload the environment"
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"

echo "install linux-firmware"
emerge --ask sys-kernel/linux-firmware

echo "installing the kernel"
https://wiki.gentoo.org/wiki/Systemd#Installation
emerge --ask sys-kernel/gentoo-sources
ln -sf /proc/self/mounts /etc/mtab

