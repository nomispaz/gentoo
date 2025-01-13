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

emerge --ask --getbinpkg app-eselect/eselect-repository

#currently no checkup of installation profiles. default for the stage-tarball is used"
# eselect profile list
# currently desktop, systemd is 28
eselect profile set 28

echo "add personal repo from github"
eselect repository add gentoo_localrepo git https://github.com/nomispaz/gentoo_localrepo.git

echo "add steam repo"
eselect repository enable steam-overlay

echo "update ebuild repo"
emerge --sync

echo "enable specific licenses"
cat <<EOF > /etc/portage/package.license
net-im/discord all-rights-reserved
app-crypt/veracrypt truecrypt-3.0
games-util/steam-launcher ValveSteamLicense
EOF

echo "set locales and time"
ln -sf ../usr/share/zoneinfo/Europe/Berlin /etc/localtime

echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "LC_MONETARY=de_DE.UTF-8" >> /etc/locale.conf
echo "LC_NUMERIC=de_DE.UTF-8" >> /etc/locale.conf
echo "LC_TIME=de_DE.UTF-8" >> /etc/locale.conf
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen
echo "KEYMAP=de-latin1" >> /etc/vconsole.conf
echo "KEYMAP=de-latin1" >> /etc/conf.d/keymaps
echo "XMGgentoo" >> /etc/hostname
locale-gen

echo "set CPU_FLAGS"
emerge --getbinpkg app-portage/cpuid2cpuflags
echo "*/* $(cpuid2cpuflags)" > /etc/portage/package.use/00cpu-flags

echo "configuring dracut"
mkdir -p /etc/dracut.conf.d/
echo "# Dracut modules to add to the default" >> /etc/dracut.conf.d/usrmount.conf
echo 'add_dracutmodules+=" usrmount "' >>  /etc/dracut.conf.d/usrmount.conf

echo "update @world set so that updates and new use-flags can be used"
emerge --ask --verbose --update --deep --newuse --getbinpkg @world

echo "reload the environment"
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"

echo "next step: run 03_chroot_install_system.sh"
