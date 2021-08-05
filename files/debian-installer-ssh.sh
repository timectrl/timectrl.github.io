#!/bin/bash
if [ $UID -ne 0 ]
then
	echo "root user only"
	exit 1
fi

set -x

wget -O /linux http://ftp.us.debian.org/debian/dists/stable/main/installer-amd64/current/images/netboot/debian-installer/amd64/linux
wget -O /initrd.gz http://ftp.us.debian.org/debian/dists/stable/main/installer-amd64/current/images/netboot/debian-installer/amd64/initrd.gz

EFI=""
if [ -f /sys/firmware/efi/runtime ]
then
	EFI="efi"
fi

sed -i '6,$d' /etc/grub.d/40_custom
cat >>/etc/grub.d/40_custom  <<ENDL
menuentry "Installer" {
#set root=(hd0,3)
set root=(hd0,$(df -h / | grep '/dev' | awk '{print $1}'|grep -Eo '[0-9]+'))
#linuxefi /linux language=en country=US locale=en_US.UTF-8 keymap=us hostname=debian-fresh domain=localhost.localdomain auto file=/hd-media/boot/preseed.txt
#linuxefi /linux language=en country=US locale=en_US.UTF-8 keymap=us hostname=debian-fresh domain=localhost.localdomain auto url=http://www.timectrl.net/files/debian-preseed.txt modules=network-console
linux${EFI} /linux language=en country=US locale=en_US.UTF-8 keymap=us hostname=debian-fresh domain=localhost.localdomain auto url=http://www.timectrl.net/files/debian-preseed-ssh.txt
initrd${EFI} /initrd.gz
}
ENDL

grub-set-default Installer || true
sed -i -e 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=Installer/g' /etc/default/grub

update-grub || (grub2-mkconfig >/boot/efi/EFI/centos/grub.cfg)


