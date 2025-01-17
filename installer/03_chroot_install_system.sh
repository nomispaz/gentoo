#install system
# base system
emerge --ask --getbinpkg \
sys-kernel/linux-firmware \
sys-kernel/gentoo-kernel-bin \
app-admin/eclean-kernel \
dev-util/ccache \
dev-util/pkgdev \
x11-terms/alacritty \
kde-apps/ark \
sys-fs/btrfs-progs \
net-misc/chrony \
sys-power/cpupower \
kde-apps/dolphin \
sys-fs/dosfstools \
sys-kernel/dracut \
sys-boot/efibootmgr \
www-client/firefox-bin \
net-firewall/firewalld \
app-shells/fish \
sys-apps/flatpak \
media-fonts/fontawesome \
dev-vcs/git \
sys-apps/gnome-disk-utility \
sys-block/gparted \
sys-boot/grub \
gnome-base/gvfs \
kde-apps/gwenview \
sys-process/htop \
kde-apps/kate \
kde-apps/konsole \
sys-apps/less \
dev-util/meld \
app-editors/neovim \
sys-fs/ntfs3g \
kde-apps/okular \
sys-boot/os-prober \
net-misc/rclone \
sys-apps/ripgrep \
app-misc/screenfetch \
app-backup/snapper \
app-admin/sudo \
media-fonts/symbols-nerd-font \
app-admin/testdisk \
media-fonts/dejavu \
app-editors/vim \
net-misc/wget \
x11-drivers/xf86-input-synaptics \
sys-fs/xfsprogs \
x11-misc/xdg-user-dirs \
x11-misc/xdg-utils \
sys-apps/apparmor \
sec-policy/apparmor-profiles \
app-antivirus/clamav \
app-forensics/lynis \
app-forensics/rkhunter \
net-wireless/blueman \
net-misc/dhcpcd \
net-wireless/iwd \
net-misc/networkmanager \
net-wireless/wpa_supplicant \
kde-plasma/plasma-meta \
x11-misc/sddm \
app-crypt/veracrypt \
app-emulation/virt-manager \
app-emulation/virtiofsd \
app-text/calibre \
www-client/brave-bin \
net-im/discord \
net-misc/yt-dlp \
app-admin/keepassxc \
app-office/libreoffice \
media-video/obs-studio \
mail-client/thunderbird \
media-sound/asunder \
app-editors/emacs \
app-emacs/yasnippet \
app-emacs/yasnippet-snippets \
app-emacs/company-mode \
app-emacs/consult \
app-emacs/go-mode \
app-emacs/rust-mode \
app-emacs/evil \
app-emacs/catppuccin-theme \
dev-lang/go \
dev-go/gopls \
dev-lang/rust-bin \
dev-python/python-lsp-server \
dev-python/flake8

# nvidia
echo "x11-drivers/nvidia-drivers dist-kernel modules tools kernel-open powerd" >> /etc/portage/package.use/nvidia
echo "x11-drivers/nvidia-drivers ~amd64" >> /etc/portage/package.accept_keywords/nvidia
echo "gui-libs/egl-x11 ~amd64" >> /etc/portage/package.accept_keywords/nvidia
echo "gui-libs/eglexternalplatform ~amd64" >> /etc/portage/package.accept_keywords/nvidia
echo "sys-devel/gcc ada d lto objc objc++ pgo" >> /etc/portage/package.use/gcc
emerge --ask --newuse --getbinpkg x11-drivers/nvidia-drivers x11-misc/prime-run

# windowmanager und sway
echo "gui-wm/sway tray" >> /etc/portage/package.use/sway
echo "gui-apps/swaybg gdk-pixbuf" >> /etc/portage/package.use/sway
echo "gui-apps/waybar tray" >> /etc/portage/package.use/waybar
echo "app-misc/brightnessctl ~amd64" >> /etc/portage/package.accept_keywords/brightnessctl
echo "dev-python/i3ipc ~amd64" >> /etc/portage/package.accept_keywords/sway
echo "x11-misc/gammastep appindicator" >> /etc/portage/package.use/gammastep
echo "gnome-extra/nm-applet appindicator" >> /etc/portage/package.use/nm-applet

emerge --ask --getbinpkg --update \
app-misc/brightnessctl \
x11-misc/dunst \
x11-misc/gammastep \
gnome-extra/nm-applet \
media-sound/pavucontrol \
x11-misc/rofi \
gui-apps/slurp \
gui-apps/grim \
gui-apps/wl-clipboard \
gui-wm/sway \
gui-apps/swaybg \
gui-apps/waybar

echo "configure sway startup"
cat <<EOF > /usr/local/bin/sway-nvidia.sh
#!/usr/bin/env bash

## Export Environment Variables
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=sway
export XDG_CURRENT_DESKTOP=sway
export XDG_CURRENT_SESSION=sway

## Qt environment
export QT_QPA_PLATFORMTHEME=qt6ct
export QT_AUTO_SCREEN_SCALE_FACTOR=1
export QT_QPA_PLATFORM=xcb
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

# Hardware cursors not yet working on wlroots
export WLR_NO_HARDWARE_CURSORS=1
# Set wlroots renderer to Vulkan to avoid flickering
#export WLR_RENDERER=vulkan
# General wayland environment variables
# Firefox wayland environment variable
#export MOZ_ENABLE_WAYLAND=1
#export MOZ_USE_XINPUT2=1
# OpenGL Variables
#export GBM_BACKEND=nvidia-drm
#export __GL_GSYNC_ALLOWED=0
#export __GL_VRR_ALLOWED=0
#export __GLX_VENDOR_LIBRARY_NAME=nvidia
# Xwayland compatibility
#export XWAYLAND_NO_GLAMOR=1

sway --unsupported-gpu
EOF

# kernel testing
echo "sys-kernel/gentoo-kernel-bin ~amd64" >> /etc/portage/package.accept_keywords/kernel
echo "virtual/dist-kernel ~amd64" >> /etc/portage/package.accept_keywords/kernel

dracut -f

echo "initialize systemd"
systemd-firstboot --prompt --setup-machine-id

echo "installing grub"
grub-install --target=x86_64-efi --efi-directory=/boot/efi

echo 'GRUB_DISABLE_OS_PROBER="false"' >> /etc/default/grub
#sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=""/GRUB_CMDLINE_LINUX_DEFAULT="quiet loglevel=3 mitigations=auto security=apparmor amd_pstate=passive nvidia_drm.modeset=1"/g' /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=""/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 mitigations=auto security=apparmor amd_pstate=passive"/g' /etc/default/grub

grub-mkconfig -o /boot/grub/grub.cfg

echo "harden installation"
echo "KRNL-5820 disable coredumps"
mkdir -p /etc/systemd/coredump.conf.d/
echo "[Coredump]" | tee -a /etc/systemd/coredump.conf.d/custom.conf
echo "Storage=none" | tee -a /etc/systemd/coredump.conf.d/custom.conf
echo "* hard core 0" | tee -a /etc/security/limits.conf
echo "* hard core 0" | tee -a /etc/security/limits.conf

echo "Improve password hash quality"
sed -i 's/#SHA_CRYPT_MIN_ROUNDS 5000/SHA_CRYPT_MIN_ROUNDS 500000/g' /etc/login.defs 
sed -i 's/#SHA_CRYPT_MAX_ROUNDS 5000/SHA_CRYPT_MAX_ROUNDS 500000/g' /etc/login.defs

echo "predefine host-file for localhost"
echo "127.0.0.1 localhost" | tee -a /etc/hosts
echo "127.0.0.1 XMGneo15Arch" | tee -a /etc/hosts

echo "set root pw"
passwd

echo "create user and set password"
echo "Enter username: "
read user
useradd -m --create-home $user
#usermod -aG sys,wheel,users,rfkill,$user,libvirt $user
usermod -aG wheel,users,video,libvirt,kvm,$user $user
passwd $user

echo "Defaults targetpw # Ask for the password of the target user" >> /etc/sudoers
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

echo "setup docker"
mkdir -p /etc/docker
cat <<EOF > /etc/docker/daemon.json
{
  "data-root": "/mnt/nvme2/data/docker/"
}
EOF

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
systemctl enable nvidia-powerd.service
systemctl enable docker.service
systemctl enable libvirtd.service

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

echo "next step: reboot"
exit
