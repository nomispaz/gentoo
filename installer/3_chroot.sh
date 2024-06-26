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

emerge --ask app-eselect/eselect-repository

#currently no checkup of installation profiles. default for the stage-tarball is used"
# eselect profile list
# currently desktop, systemd is 24
eselect profile set 24

echo "add personal repo from github"
eselect repository add gentoo_localrepo git https://github.com/nomispaz/gentoo_localrepo.git

echo "add steam repo"
eselect repository enable steam-overlay

echo "update ebuild repo"
emerge --sync

echo "adding first use-flags"
echo 'USE="-elogind initramfs redistributable systemd X wayland"' >> /etc/portage/make.conf

echo "set makeopts"
echo 'MAKEOPTS="--jobs 8 --load-average 9"' >> /etc/portage/make.conf

echo "enable masked packages"
cat <<EOF > /etc/portage/package.accept_keywords/packages
app-forensics/lynis ~amd64
gui-wm/hyprland ~amd64
x11-terms/kitty ~amd64
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
dev-libs/wayland-protocols ~amd64
x11-drivers/nvidia-drivers ~amd64
sys-firmware/nvidia-firmware ~amd64
#sys-kernel/gentoo-kernel-bin ~amd64
=sys-kernel/gentoo-sources-6.4* ~amd64
virtual/dist-kernel-6.4* ~amd64
x11-misc/sddm ~amd64
sys-kernel/gentoo-kernel-6.4* ~amd64
media-video/obs-studio ~amd64
gui-wm/gamescope ~amd64
media-libs/vkroots ~amd64
games-util/mangohud ~amd64
app-backup/mkstage4 ~amd64
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
media-libs/mesa wayland abi_x86_32
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
x11-drivers/nvidia-drivers dist-kernel modules wayland tools kernel-open
media-libs/libsdl2 gles2
media-fonts/fontawesome ttf
x11-libs/libX11  abi_x86_32
x11-libs/libXau  abi_x86_32
x11-libs/libxcb  abi_x86_32
x11-libs/libXdmcp  abi_x86_32
virtual/opengl  abi_x86_32
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
app-arch/bzip2 abi_x86_32
x11-libs/libpciaccess abi_x86_32
dev-libs/wayland abi_x86_32
dev-qt/qtbase opengl egl
dev-qt/qtdeclarative opengl
x11-terms/kitty wayland
gui-apps/swaybg gdk-pixbuf
gui-wm/sway wallpapers
sys-apps/xdg-desktop-portal-gtk wayland
app-laptop/tuxedo-keyboard dist-kernel
games-util/steam-launcher ValveSteamLicense
EOF

echo "enable specific licenses"
cat <<EOF > /etc/portage/package.license
net-im/discord all-rights-reserved
app-crypt/veracrypt truecrypt-3.0
games-util/steam-launcher ValveSteamLicense
EOF

echo "add licenses to make.conf"
echo 'ACCEPT_LICENSE="@FREE @GPL-COMPATIBLE @BINARY-REDISTRIBUTABLE"' >> /etc/portage/make.conf
echo "add grub platform"
echo 'GRUB_PLATFORMS="efi-64"' >> /etc/portage/make.conf

echo "add video-cards to make.conf"
echo 'VIDEO_CARDS="amdgpu radeonsi radeon nvidia"' >> /etc/portage/make.conf

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

echo "next step: run 4_chroot_install_system.sh"
