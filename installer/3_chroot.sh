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

#skipping use-variables and use default

echo "set CPU_FLAGS"
emerge --ask app-portage/cpuid2cpuflags
echo "*/* $(cpuid2cpuflags)" > /etc/portage/package.use/00cpu-flags

# skipping licenses for now

