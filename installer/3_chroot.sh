echo "if anything happens, it should be able to continue from here"
source /etc/profile
export PS1="(chroot) ${PS1}"

blkid

echo "generate fstab"
echo "enter root partition"
read rootDev
rootDrive=$(blkid -s UUID -o value /dev/$rootDev)

echo "UUID=$rootDrive / btrfs defaults,noatime,compress=zstd,subvol=root 0 0" >> /etc/fstab
echo "UUID=$rootDrive /home btrfs defaults,noatime,compress=zstd,subvol=home 0 0" >> /etc/fstab
echo "UUID=$rootDrive /data btrfs defaults,noatime,compress=zstd,subvol=data 0 0" >> /etc/fstab
echo "UUID=$rootDrive /var btrfs defaults,noatime,compress=zstd,subvol=var 0 0" >> /etc/fstab
echo "UUID=$rootDrive /.snapshots btrfs defaults,noatime,compress=zstd,subvol=snapshots 0 0" >> /etc/fstab

echo "update ebuild repo"
emerge --sync

#currently no checkup of installation profiles. default for the stage-tarball is used"
# eselect profile list
# currently plasma, systemd is 10; only systemd is 22
eselect profile set 22

#echo "update @world set so that updates and new use-flags can be used"
emerge --ask --verbose --update --deep --newuse @world

echo "adding first use-flags"
echo 'USE="-elogind initramfs redistributable systemd sysv-utils"' >> /etc/portage/make.conf

echo "set CPU_FLAGS"
emerge app-portage/cpuid2cpuflags
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
echo "KEYMAP=de-latin1" >> /etc/conf.d/keymaps
echo "XMGgentoo" >> /etc/hostname
locale-gen

echo "reload the environment"
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"

echo "configuring dracut"
mkdir -p /etc/dracut.conf.d/
echo "# Dracut modules to add to the default" >> /etc/dracut.conf.d/usrmount.conf
echo 'add_dracutmodules+=" usrmount "' >>  /etc/dracut.conf.d/usrmount.conf

#install system
#emerge     kde-plasma/plasma-meta   
emerge \
sys-kernel/linux-firmware \
sys-kernel/gentoo-kernel-bin \
sys-fs/btrfs-progs \
sys-kernel/dracut \
net-misc/dhcpcd \
net-misc/networkmanager \
net-wireless/iwd \
net-wireless/wpa_supplicant \
sys-boot/grub \
sys-boot/efibootmgr \
sys-libs/timezone-data \
dev-vcs/git \
sys-apps/systemd \
app-portage/gentoolkit \
app-admin/sudo \
x11-terms/kitty \
sys-apps/grep \
app-editors/nano \
sys-process/htop \
net-misc/wget \
x11-misc/xdg-user-dirs \
x11-misc/xdg-utils \
x11-drivers/xf86-input-libinput \
gnome-base/gnome-keyring \
net-wireless/wireless-tools \
media-video/pipewire \
media-video/wireplumber \
media-libs/libpulse \
dev-libs/wayland \
x11-base/xwayland \
dev-qt/qtwayland \
kde-apps/dolphin \
media-video/ffmpeg \
kde-apps/ffmpegthumbs \
kde-apps/kate \
kde-apps/kio-extras \
kde-frameworks/breeze-icons \
kde-apps/ark \
sys-power/acpid \
media-sound/alsa-utils \
sys-apps/apparmor \
sys-apps/apparmor-utils \
net-wireless/bluez \
app-antivirus/clamav \
net-print/cups \
sys-auth/polkit \
sys-fs/exfatprogs \




#skip fileindexing for now
#emerge sys-apps/mlocate

echo "installing the kernel"
emerge sys-kernel/gentoo-kernel-bin

#https://wiki.gentoo.org/wiki/Systemd#Installation
#emerge sys-kernel/gentoo-sources
#ln -sf /proc/self/mounts /etc/mtab

#eselect kernel set 1
#emerge sys-kernel/genkernel
#genkernel --menuconfig --btrfs --virtio all

dracut -f

echo "set root pw"
passwd

echo "initialize systemd"
systemd-firstboot --prompt --setup-machine-id

echo "installing grub"
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

echo "Enable Services"
systemctl enable systemd-networkd.service
systemctl enable systemd-resolved.service
systemctl enable sddm.service
systemctl enable NetworkManager.service
systemctl enable dhcpcd.service
systemctl enable systemd-timesyncd.service
systemctl enable wireplumber.service
systemctl enable acpid.service
systemctl enable bluetooth.service

echo "next steps: check fstab, cd, umount -l /mnt/gentoo/dev{/shm,/pts,}, umount -R /mnt/gentoo, reboot"
exit
