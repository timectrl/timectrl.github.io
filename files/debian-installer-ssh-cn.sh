#!/bin/bash
if [ $UID -ne 0 ]
then
	echo "root user only"
	exit 1
fi

set -x

PREFIX=$(df -h /boot/|grep dev|awk '{print $6}')
wget -O ${PREFIX}/linux http://cdn-aws.deb.debian.org/debian/dists/stable/main/installer-amd64/current/images/netboot/debian-installer/amd64/linux
wget -O ${PREFIX}/initrd.gz http://cdn-aws.deb.debian.org/debian/dists/stable/main/installer-amd64/current/images/netboot/debian-installer/amd64/initrd.gz

EFI=""
if [ -f /sys/firmware/efi/runtime ]
then
	EFI="efi"
fi

sed -i '6,$d' /etc/grub.d/40_custom
cat >>/etc/grub.d/40_custom  <<ENDL
menuentry "Installer" {
#set root=(hd0,3)
set root=(hd0,$(df -h /boot | grep '/dev' | awk '{print $1}'|grep -Eo '[0-9]+'))
#linuxefi /linux language=en country=US locale=en_US.UTF-8 keymap=us hostname=debian-fresh domain=localhost.localdomain lowmem/low=true auto file=/hd-media/boot/preseed.txt
#linuxefi /linux language=en country=US locale=en_US.UTF-8 keymap=us hostname=debian-fresh domain=localhost.localdomain lowmem/low=true auto url=http://www.timectrl.net/files/debian-preseed.txt modules=network-console
linux${EFI} /linux language=en country=US locale=en_US.UTF-8 keymap=us hostname=debian-fresh domain=localhost.localdomain lowmem/low=true auto url=http://www.timectrl.net/files/debian-preseed-ssh-cn.txt
initrd${EFI} /initrd.gz
}
ENDL

grub-set-default Installer || true
sed -i -e 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=Installer/g' /etc/default/grub

update-grub
find /boot -name grub.cfg |xargs -i grub2-mkconfig -o {}


