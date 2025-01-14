#install system
# base system
emerge --update --getbinpkg \
sys-kernel/linux-firmware \
sys-kernel/gentoo-kernel-bin \
x11-terms/alacritty \
kde-apps/ark \
sys-fs/btrfs-progs \
net-misc/chrony \
sys-power/cpupower \
kde-apps/dolphin \
sys-kernel/dracut \
sys-boot/efibootmgr \
www-client/firefox-bin \
net-firewall/firewalld \
app-shells/fish \
sys-apps/flatpak \
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
kde-apps/okular \
sys-boot/os-prober \
net-misc/rclone \
sys-apps/ripgrep \
app-misc/screenfetch \
app-backup/snapper \
app-admin/sudo \
app-admin/testdisk \
media-fonts/dejavu \
media-fonts/nerd-fonts-symbols \
app-editors/vim \
net-misc/wget \
x11-drivers/xf86-input-synaptics \
sys-fs/xfsprogs \
x11-misc/xdg-user-dirs \
x11-misc/xdg-utils

#security
emerge --ask --update --getbinpkg \
sys-apps/apparmor \
sec-policy/apparmor-profiles \
app-antivirus/clamav \
app-forensics/rkhunter

# networking
emerge --ask --update --getbinpkg \
net-misc/dhcpcd \
net-wireless/iwd \
net-misc/networkmanager \
net-wireless/wpa_supplicant

# kde plasma
emerge --update --getbinpkg \
kde-plasma/plasma-meta \
x11-misc/sddm

# additional programs
emerge --update --getbinpkg \
app-crypt/veracrypt \
app-emulation/virt-manager \
app-emulation/virtiofsd \
app-text/calibre \
net-misc/yt-dlp \
app-admin/keepassxc \
app-office/libreoffice \
media-video/obs-studio \
mail-client/thunderbird \
media-sound/asunder

#emacs
emerge --update --getbinpkg \
app-editors/emacs \
app-emacs/yasnippet \
app-emacs/yasnippet-snippets \
app-emacs/company-mode \
app-emacs/consult \
app-emacs/go-mode \
app-emacs/rust-mode \
app-emacs/evil

dracut -f

echo "initialize systemd"
systemd-firstboot --prompt --setup-machine-id

echo "installing grub"
grub-install --target=x86_64-efi --efi-directory=/boot/efi

echo 'GRUB_DISABLE_OS_PROBER="false"' >> /etc/default/grub
#sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=""/GRUB_CMDLINE_LINUX_DEFAULT="quiet loglevel=3 mitigations=auto security=apparmor amd_pstate=passive nvidia_drm.modeset=1"/g' /etc/default/grub
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT=""/GRUB_CMDLINE_LINUX_DEFAULT="quiet loglevel=3 mitigations=auto security=apparmor amd_pstate=passive"/g' /etc/default/grub

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
usermod -aG sys,wheel,users,rfkill,pipewire,$user $user
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

echo "next step: reboot"
exit
