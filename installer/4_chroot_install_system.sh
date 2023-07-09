#install system
#emerge     kde-plasma/plasma-meta   
emerge --update \
sys-kernel/linux-firmware \
sys-kernel/gentoo-kernel-bin \
sys-fs/btrfs-progs \
sys-kernel/dracut \
net-misc/dhcpcd \
net-misc/networkmanager \
net-wireless/iwd \
net-wireless/wpa_supplicant \
sys-boot/grub \
sys-boot/os-prober \
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
sys-auth/rtkit
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
sec-policy/apparmor-profiles \
sys-apps/apparmor-utils \
net-wireless/bluez \
app-antivirus/clamav \
net-print/cups \
sys-auth/polkit \
sys-fs/exfatprogs \
www-client/firefox-bin \
net-firewall/firewalld \
net-print/gutenprint \
net-print/hplip \
sys-fs/mtpfs \
sys-apps/hwinfo 
net-fs/nfs-utils \
sys-fs/ntfs3g \
app-forensics/rkhunter \
net-misc/rsync \
app-arch/unrar \
app-arch/unzip \
gui-libs/xdg-desktop-portal-hyprland \
gui-libs/xdg-desktop-portal \
app-shells/zsh \
app-shells/zsh-completions \
app-shells/gentoo-zsh-completions \
dev-util/meld \
kde-apps/kompare \
sys-block/gparted \
x11-misc/sddm \
app-misc/screenfetch \
sys-power/cpupower \
app-backup/snapper \
gui-wm/hyprland \
dev-libs/hyprland-protocols \
x11-misc/qt5ct \
media-libs/libva \
gnome-extra/nm-applet \
gui-apps/wofi \
gui-apps/waybar \
media-sound/pavucontrol \
x11-misc/dunst \
gui-apps/swaylock \
sci-libs/libqalculate \
gui-apps/swaybg \
app-misc/ranger \
media-gfx/w3mimgfb \
x11-misc/xsel \
net-misc/chrony \
app-forensics/lynis \
app-portage/genlop \
app-misc/brightnessctl \
dev-util/pkgdev \
x11-misc/prime-run \
games-util/steam-launcher \
sys-apps/flatpak

finishInstallation="n"
echo "Check for install errors. Continue? [Y/n]"
read finishInstallation

if ! [[ "$finishInstallation" == "N" || "$finishInstallation" == "n" ]]
then
    echo "Cancelling Installation"
else
echo "Continuing installation"
echo "Install tuxedo-packages"
emerge --update \
app-laptop/tuxedo-control-center-bin \
app-laptop/tuxedo-keyboard

#skip fileindexing for nowge
#emerge sys-apps/mlocate

#https://wiki.gentoo.org/wiki/Systemd#Installation
#emerge sys-kernel/gentoo-sources
#ln -sf /proc/self/mounts /etc/mtab

#eselect kernel set 1
#emerge sys-kernel/genkernel
#genkernel --menuconfig --btrfs --virtio all

dracut -f

echo "initialize systemd"
systemd-firstboot --prompt --setup-machine-id

echo "installing grub"
grub-install --target=x86_64-efi --efi-directory=/boot/efi
grub-mkconfig -o /boot/grub/grub.cfg

echo "harden installation"
echo "KRNL-5820 disable coredumps"
echo "* hard core 0" | tee -a /etc/security/limits.conf
echo "* hard core 0" | tee -a /etc/security/limits.conf

echo "Improve password hash quality"
sed -i 's/#SHA_CRYPT_MIN_ROUNDS 5000/SHA_CRYPT_MIN_ROUNDS 500000/g' /etc/login.defs 
sed -i 's/#SHA_CRYPT_MAX_ROUNDS 5000/SHA_CRYPT_MAX_ROUNDS 500000/g' /etc/login.defs

echo "set root pw"
passwd

echo "create user and set password"
echo "Enter username: "
read user
useradd -m --create-home $user
#usermod -aG sys,wheel,users,rfkill,$user,libvirt $user
usermod -aG sys,wheel,users,rfkill,$user $user
passwd $user

echo "Defaults targetpw # Ask for the password of the target user" >> /etc/sudoers
echo "$user ALL=(ALL:ALL) ALL" >> /etc/sudoers

echo "Enable Services"
systemctl enable systemd-networkd.service
systemctl enable systemd-resolved.service
systemctl enable sddm.service
systemctl enable NetworkManager.service
systemctl enable dhcpcd.service
systemctl enable systemd-timesyncd.service
systemctl enable acpid.service
systemctl enable bluetooth.service
systemctl enable chronyd.service
systemctl enable firewalld.service
systemctl enable apparmor.service

systemctl enable tccd.service

firewall-cmd --set-default-zone block

echo "Setup snapper"
umount /.snapshots
rm -r /.snapshots
snapper -c root create-config /
#read UUID of rootpartition and write into variable
rootUUID=$(cat /etc/fstab | sed -nE 's/.*UUID=(.*)+ \/.*+root.*$/\1/p')
mount -o subvol=snapshots UUID=$rootUUID /.snapshots
chmod 750 /.snapshots/

#https://www.gentoo.org/support/news-items/2022-07-29-pipewire-sound-server.html
#enable pipewire
sudo mkdir -p /etc/pipewire
sudo cp /usr/share/pipewire/pipewire.conf /etc/pipewire/pipewire.conf

echo "next steps: check fstab, cd, umount -l /mnt/gentoo/dev{/shm,/pts,}, umount -R /mnt/gentoo, reboot"
exit
fi
