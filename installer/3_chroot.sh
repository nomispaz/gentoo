echo "if anything happens, it should be able to continue from here"
source /etc/profile
export PS1="(chroot) ${PS1}"

blkid

echo "generate fstab"
echo "enter root partition"
read rootDev
rootDrive=$(blkid -s UUID -o value /dev/$rootDev)

echo "UUID=$rootDrive / noatime,compress=zstd,subvol=/root 0 0" >> /etc/fstab
echo "UUID=$rootDrive /home noatime,compress=zstd,subvol=/home 0 0" >> /etc/fstab
echo "UUID=$rootDrive /data noatime,compress=zstd,subvol=/data 0 0" >> /etc/fstab
echo "UUID=$rootDrive /var/log noatime,compress=zstd,subvol=/var_log 0 0" >> /etc/fstab
echo "UUID=$rootDrive /var/cache noatime,compress=zstd,subvol=/var_cache 0 0" >> /etc/fstab
echo "UUID=$rootDrive /.snapshots noatime,compress=zstd,subvol=/snapshots 0 0" >> /etc/fstab

echo "choose install profile"
eselect profile list

echo "update ebuild repo"
emerge --sync

#currently no checkup of installation profiles. default for the stage-tarball is used"
# eselect profile list
# eselect profile set xxx

#echo "update @world set so that updates and new use-flags can be used"
#emerge --ask --verbose --update --deep --newuse @world

echo "adding first use-flags"
echo 'USE="-elogind initramfs redistributable systemd sysv-utils"' >> /etc/portage/make.conf

echo "set CPU_FLAGS"
emerge --ask app-portage/cpuid2cpuflags
echo "*/* $(cpuid2cpuflags)" > /etc/portage/package.use/00cpu-flags

echo "add licenses to make.conf"
echo 'ACCEPT_LICENSE="@FREE @GPL-COMPATIBLE @BINARY-REDISTRIBUTABLE"' >> /etc/portage/make.conf
echo "add grub platform"
echo 'GRUB_PLATFORMS="efi-64"' >> /etc/portage/make.conf

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

echo "install btrfs-progs"
emerge --ask sys-fs/btrfs-progs

echo "installing the kernel"
#https://wiki.gentoo.org/wiki/Systemd#Installation
#emerge --ask sys-kernel/gentoo-sources
#ln -sf /proc/self/mounts /etc/mtab

echo "installing dracut"
mkdir -p /etc/dracut.conf.d/
echo "# Dracut modules to add to the default" >> /etc/dracut.conf.d/usrmount.conf
echo 'add_dracutmodules+=" usrmount "' >>  /etc/dracut.conf.d/usrmount.conf
emerge --ask sys-kernel/dracut

#eselect kernel set 1
#emerge --ask sys-kernel/genkernel
#genkernel --menuconfig --btrfs --virtio all

emerge --ask sys-kernel/gentoo-kernel-bin

dracut -f

echo "install dhcp clien"
emerge --ask net-misc/dhcpcd

echo "set root pw"
passwd

echo "initialize systemd"
systemd-firstboot --prompt --setup-machine-id

#skip fileindexing for now
#emerge --ask sys-apps/mlocate

echo "enable time synchronisation"
systemctl enable systemd-timesyncd.service

echo "install wlan tools"
emerge --ask net-wireless/iw net-wireless/wpa_supplicant

echo "installing grub"
emerge --ask sys-boot/grub
grub-install --target=x86_64-efi --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg

#skip efi bootmgr for now

echo "create user and set password"
echo "Enter username: "
read user
useradd -m --create-home $user
#usermod -aG sys,wheel,users,rfkill,$user,libvirt $user
usermod -aG sys,wheel,users,rfkill,$user $user
passwd $user

echo "Defaults targetpw # Ask for the password of the target user" >> /etc/sudoers
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

echo "next steps: check fstab, cd, umount -l /mnt/gentoo/dev{/shm,/pts,}, umount -R /mnt/gentoo, reboot"
exit
