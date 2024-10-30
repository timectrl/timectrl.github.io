#!/bin/bash
if [ $UID -ne 0 ]
then
	echo "root user only"
	exit 1
fi

set -x

MIRROR_PREFIX="http://deb.debian.org/debian"
MIRROR_PREFIX="http://ftp.debian.org/debian"
MIRROR_PREFIX="http://ftp.us.debian.org/debian"
MIRROR_PREFIX="http://ftp.cn.debian.org/debian"
MIRROR_PREFIX="http://cdn-aws.deb.debian.org/debian"

VER=stable

MIRROR_PREFIX="${MIRROR_PREFIX}/${VER}"

ROOT_PREFIX=$(df -h /boot/|grep dev|head -n 1|awk '{print $6}')
ROOT_DEVICE=$(df -h /boot/|grep dev|head -n 1|awk '{print $1}')
ROOT_UUID=$(blkid ${ROOT_DEVICE}|sed -e 's/ /\n/g'|grep ^UUID|sed -e 's/^[^"]*"\?//g' -e 's/"\?[^"]*$//g')

wget -O ${ROOT_PREFIX}/linux ${MIRROR_PREFIX}/main/installer-amd64/current/images/netboot/debian-installer/amd64/linux
wget -O ${ROOT_PREFIX}/initrd.gz ${MIRROR_PREFIX}/main/installer-amd64/current/images/netboot/debian-installer/amd64/initrd.gz

EFI=""
if [ -f /sys/firmware/efi/runtime ]
then
	EFI="efi"
fi

sed -i '6,$d' /etc/grub.d/40_custom
cat >>/etc/grub.d/40_custom  <<ENDL
menuentry "Installer" {
#set root=(hd0,3)
#set root=(hd0,$(df -h /boot | grep '/dev' | awk '{print $1}'|grep -Eo '[0-9]+'))
search --no-floppy --fs-uuid --set ${ROOT_UUID}
#linuxefi /linux language=en country=US locale=en_US.UTF-8 keymap=us hostname=debian-fresh domain=localhost.localdomain lowmem/low=true auto file=/hd-media/boot/debian-preseed.txt
linux${EFI} /linux language=en country=US locale=en_US.UTF-8 keymap=us hostname=debian-fresh domain=localhost.localdomain lowmem/low=true auto url=http://www.timectrl.net/files/debian-preseed.txt
initrd${EFI} /initrd.gz
}

menuentry "Installer -ssh +autofs" {
#set root=(hd0,3)
#set root=(hd0,$(df -h /boot | grep '/dev' | awk '{print $1}'|grep -Eo '[0-9]+'))
search --no-floppy --fs-uuid --set ${ROOT_UUID}
#linuxefi /linux language=en country=US locale=en_US.UTF-8 keymap=us hostname=debian-fresh domain=localhost.localdomain lowmem/low=true auto file=/hd-media/boot/debian-preseed-autofs.txt
linux${EFI} /linux language=en country=US locale=en_US.UTF-8 keymap=us hostname=debian-fresh domain=localhost.localdomain lowmem/low=true auto url=http://www.timectrl.net/files/debian-preseed-autofs.txt
initrd${EFI} /initrd.gz
}
ENDL

grub-set-default Installer || true
sed -i -e 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=Installer/g' /etc/default/grub

update-grub
find /boot -name grub.cfg |xargs -i grub2-mkconfig -o {}


