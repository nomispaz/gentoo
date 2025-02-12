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
echo "UUID=$rootDrive /swap btrfs defaults,noatime,compress=zstd,subvol=swap 0 0" >> /etc/fstab
echo "/swap/swapfile      	none      	swap      	defaults  	0 0" >> /etc/fstab

# necessary at this point so that the profile selection works
echo "update ebuild repo"
emerge --sync

emerge --getbinpkg app-eselect/eselect-repository

#currently no checkup of installation profiles. default for the stage-tarball is used"
# eselect profile list
# currently desktop, systemd is 28
eselect profile set 28

echo "add personal repo from github"
eselect repository add gentoo_localrepo git https://github.com/nomispaz/gentoo_localrepo.git

echo "add steam repo"
eselect repository enable steam-overlay

#add brave-overlay
eselect repository add brave-overlay git https://gitlab.com/jason.oliveira/brave-overlay.git

echo "enable specific licenses"
cat <<EOF > /etc/portage/package.license
net-im/discord all-rights-reserved
app-crypt/veracrypt truecrypt-3.0
games-util/steam-launcher ValveSteamLicense
dev-util/nvidia-cuda-toolkit NVIDIA-CUDA
EOF

echo "set locales and time"
ln -sf ../usr/share/zoneinfo/Europe/Berlin /etc/localtime

echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "LC_MONETARY=de_DE.UTF-8" >> /etc/locale.conf
echo "LC_NUMERIC=de_DE.UTF-8" >> /etc/locale.conf
echo "LC_TIME=de_DE.UTF-8" >> /etc/locale.conf
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen
echo "KEYMAP=de-latin1" > /etc/vconsole.conf
echo 'KEYMAP="de-latin1"' > /etc/conf.d/keymaps
echo "XMGgentoo" >> /etc/hostname
locale-gen

echo "set keyboard layout for sddm"
mkdir -p /etc/X11/xorg.conf.d/
touch /etc/X11/xorg.conf.d/00-keyboard.conf
cat <<EOF >/etc/X11/xorg.conf.d/00-keyboard.conf
# Written by systemd-localed(8), read by systemd-localed and Xorg. It's
# probably wise not to edit this file manually. Use localectl(1) to
# instruct systemd-localed to update it.
Section "InputClass"
        Identifier "system-keyboard"
        MatchIsKeyboard "on"
        Option "XkbLayout" "de"
        Option "XkbModel" "microsoftpro"
        Option "XkbVariant" "nodeadkeys"
        Option "XkbOptions" "terminate:ctrl_alt_bksp"
EndSection
EOF

### NVIDIA patches ###
echo "wlroots-patch for nvidia"
mkdir -p /etc/portage/patches/gui-libs/wlroots/
cat <<EOF > /etc/portage/patches/gui-libs/wlroots/nvidia.patch
--- a/render/gles2/pass.c	2023-12-21 13:42:26.000000000 -0500
+++ b/render/gles2/pass.c	2024-02-26 22:47:46.731134932 -0500
@@ -36,7 +36,7 @@
 		clock_gettime(CLOCK_MONOTONIC, &timer->cpu_end);
 	}

-	glFlush();
+	glFinish();
 	glBindFramebuffer(GL_FRAMEBUFFER, 0);

 	pop_gles2_debug(renderer);
EOF

echo "sway-patch for nvidia"
mkdir -p /etc/portage/patches/gui-wm/sway/
cat <<EOF > /etc/portage/patches/gui-wm/sway/nvidia.patch
--- a/sway.desktop	2025-01-16 07:45:40.038682656 +0100
+++ b/sway.desktop	2025-01-16 07:47:34.292733051 +0100
@@ -1,5 +1,5 @@
 [Desktop Entry]
 Name=Sway
 Comment=An i3-compatible Wayland compositor
-Exec=/usr/local/bin/sway-nvidia.sh
+Exec=sway
 Type=Application
EOF


#echo "set CPU_FLAGS"
#emerge --getbinpkg app-portage/cpuid2cpuflags
#echo "*/* $(cpuid2cpuflags)" > /etc/portage/package.use/00cpu-flags

echo "set use-flags"
echo "sys-kernel/installkernel dracut grub -systemd" >> /etc/portage/package.use/kernel
echo "sys-boot/grub mount" >> /etc/portage/package.use/grub
echo "dev-python/pyqt6 gui network opengl printsupport quick svg widgets" >> /etc/portage/package.use/qt
echo "media-libs/harfbuzz icu graphite" >> /etc/portage/package.use/harfbuzz
echo "gui-libs/gtk -cpu_flags_x86_f16c" >> /etc/portage/package.use/gtk
echo "dev-libs/boost -icu" >> /etc/portage/package.use/boost
echo "sys-process/lsof rpc" >> /etc/portage/package.use/lsof
echo "app-admin/testdisk -gui -jpeg" >> /etc/portage/package.use/testdisk
echo "sys-fs/xfsprogs -icu" >> /etc/portage/package.use/xfsprogs
echo "mail-client/thunderbird lto" >> /etc/portage/package.use/thunderbird
echo "media-video/ffmpeg opus" >> /etc/portage/package.use/ffmpeg
echo "net-libs/nodejs -inspector" >> /etc/portage/package.use/nodejs
echo "dev-qt/qtwebengine bindist" >> /etc/portage/package.use/qt
echo "net-libs/gnutls tools pkcs11" >> /etc/portage/package.use/gnutls
echo "net-misc/spice-gtk usbredir" >> /etc/portage/package.use/spice-gtk
echo "net-dns/dnsmasq script" >> /etc/portage/package.use/dnsmasq
echo "app-containers/docker cuda btrfs" >> /etc/portage/package.use/docker
echo "app-containers/containerd btrfs" >> /etc/portage/package.use/docker
echo "dev-lang/rust-bin rust-analyzer rustfmt" >> /etc/portage/package.use/rust
echo "app-emulation/qemu spice pulseaudio" >> /etc/portage/package.use/qemu
echo "app-emulation/libvirt firewalld" >> /etc/portage/package.use/libvirt

# testing branch
echo "media-video/obs-studio ~amd64" >> /etc/portage/package.accept_keywords/obs-studio
# personal repo
echo "media-fonts/nerd-fonts-symbols ~amd64" >> /etc/portage/package.accept_keywords/fonts
echo "app-forensics/lynis ~amd64" >> /etc/portage/package.accept_keywords/lynis
echo "dev-libs/libpthread-stubs **" >> /etc/portage/package.accept_keywords/brave

echo "update ebuild repo"
emerge --sync

echo "configuring dracut"
mkdir -p /etc/dracut.conf.d/
echo "# Dracut modules to add to the default" >> /etc/dracut.conf.d/usrmount.conf
echo 'add_dracutmodules+=" usrmount "' >>  /etc/dracut.conf.d/usrmount.conf

echo "update @world set so that updates and new use-flags can be used"
emerge --ask --verbose --update --deep --newuse --getbinpkg @world

echo "reload the environment"
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"

echo "next step: run 03_chroot_install_system.sh"
