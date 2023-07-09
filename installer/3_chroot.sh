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

#currently no checkup of installation profiles. default for the stage-tarball is used"
# eselect profile list
# currently desktop, systemd is 12; only systemd is 22, systemd, plasma is 10
eselect profile set 12

echo "add personal repo from github"
eselect repository add gentoo_localrepo git https://github.com/nomispaz/gentoo_localrepo.git

echo "add steam repo"
eselect repository enable steam-overlay

echo "update ebuild repo"
emerge --sync

echo "adding first use-flags"
echo 'USE="-elogind initramfs redistributable systemd"' >> /etc/portage/make.conf

echo "set makeopts"
echo 'MAKEOPTS="--jobs 8 --load-average 9"' >> /etc/portage/make.conf

echo "enable masked packages"
cat <<EOF > /etc/portage/package.accept_keywords/packages
app-forensics/lynis ~amd64
gui-wm/hyprland ~amd64
x11-terms/kitty* ~amd64
gui-apps/waybar ~amd64
dev-libs/hyprland-protocols ~amd64
dev-libs/date ~amd64
dev-libs/libliftoff ~amd64
media-libs/libdisplay-info ~amd64
gui-apps/wofi ~amd64
media-gfx/w3mimgfb ~amd64
app-laptop/tuxedo-keyboard ~amd64
app-laptop/tuxedo-control-center-bin ~amd64
*/*::steam-overlay
games-util/game-device-udev-rules ~amd64
app-shells/zsh-autosuggestions ~amd64
app-shells/zsh-history-substring-search ~amd64
gui-libs/xdg-desktop-portal-hyprland ~amd64
dev-qt/qtbase ~amd64
dev-qt/qtwayland ~amd64
dev-qt/qtdeclarative ~amd64
dev-qt/qtshadertools ~amd64
app-misc/brightnessctl ~amd64
gui-libs/xdg-desktop-portal-hyprland ~amd64
EOF

echo "adding use-flags to packages"
cat <<EOF > /etc/portage/package.use/packages
gui-apps/waybar experimental tray pipewire network wifi pulseaudio
gui-libs/wlroots x11-backend
sys-process/lsof rpc
net-dns/avahi python
sys-boot/grub mount
gnome-extra/nm-applet appindicator
dev-libs/libdbusmenu gtk3
media-video/pipewire sound-server gstreamer jack-client pipwire-alsa dbus
media-video/wireplumber systemd
media-sound/pulseaudio -daemon
media-libs/libcanberra alsa
x11-libs/cairo X
x11-libs/pango X
dev-cpp/gtkmm X
dev-cpp/cairomm X
media-libs/libglvnd X
x11-libs/gtk+ wayland
dev-qt/qtgui dbus egl
x11-libs/libxkbcommon X
media-libs/mesa wayland
kde-frameworks/kwindowsystem X
kde-frameworks/kconfig dbus
dev-qt/qtcore icu
net-firewall/nftables xtables json python
sys-apps/systemd policykit
app-text/ghostscript-gpl cups
media-video/vlc dbus ogg
media-sound/jack2 dbus
app-crypt/gcr gtk
app-text/xmlto text
net-wireless/wpa_supplicant dbus
dev-qt/qtmultimedia widgets
x11-drivers/nvidia-drivers dist-kernel
media-libs/libsdl2 gles2
x11-drivers/nvidia-drivers wayland
media-fonts/fontawesome ttf
x11-libs/libX11  abi_x86_32
x11-libs/libXau  abi_x86_32
x11-libs/libxcb  abi_x86_32
x11-libs/libXdmcp  abi_x86_32
virtual/opengl  abi_x86_32
media-libs/mesa  abi_x86_32
dev-libs/expat  abi_x86_32
media-libs/libglvnd  abi_x86_32
sys-libs/zlib  abi_x86_32
x11-libs/libdrm  abi_x86_32
x11-libs/libxshmfence  abi_x86_32
x11-libs/libXext  abi_x86_32
x11-libs/libXxf86vm  abi_x86_32
x11-libs/libXfixes  abi_x86_32
app-arch/zstd  abi_x86_32
sys-devel/llvm  abi_x86_32
x11-libs/libXrandr  abi_x86_32
x11-libs/libXrender  abi_x86_32
dev-libs/libffi  abi_x86_32
sys-libs/ncurses  abi_x86_32 -gpm
dev-libs/libxml2  abi_x86_32
dev-libs/icu  abi_x86_32
sys-libs/gpm  abi_x86_32
virtual/libelf  abi_x86_32
dev-libs/elfutils  abi_x86_32
EOF

echo "add licenses to make.conf"
echo 'ACCEPT_LICENSE="@FREE @GPL-COMPATIBLE @BINARY-REDISTRIBUTABLE"' >> /etc/portage/make.conf
echo "add grub platform"
echo 'GRUB_PLATFORMS="efi-64"' >> /etc/portage/make.conf

echo "add video-cards to make.conf"
VIDEO_CARDS="amdgpu radeonsi radeon nvidia"

echo "set locales and time"
ln -sf ../usr/share/zoneinfo/Europe/Berlin /etc/localtime

echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen
echo "KEYMAP=de-latin1" >> /etc/vconsole.conf
echo "KEYMAP=de-latin1" >> /etc/conf.d/keymaps
echo "XMGgentoo" >> /etc/hostname
locale-gen

echo "set CPU_FLAGS"
emerge app-portage/cpuid2cpuflags
echo "*/* $(cpuid2cpuflags)" > /etc/portage/package.use/00cpu-flags

echo "configuring dracut"
mkdir -p /etc/dracut.conf.d/
echo "# Dracut modules to add to the default" >> /etc/dracut.conf.d/usrmount.conf
echo 'add_dracutmodules+=" usrmount "' >>  /etc/dracut.conf.d/usrmount.conf

echo "update @world set so that updates and new use-flags can be used"
emerge --ask --verbose --update --deep --newuse @world

echo "reload the environment"
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"


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
