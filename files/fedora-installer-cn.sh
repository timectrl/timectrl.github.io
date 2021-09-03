#!/bin/bash
if [ $UID -ne 0 ]
then
	echo "root user only"
	exit 1
fi

set -x


MIRROR_PREFIX=https://dl.fedoraproject.org/pub/fedora/linux/releases/34/
MIRROR_PREFIX=https://mirror.sjtu.edu.cn/fedora/linux/releases/34
MIRROR_PREFIX=http://mirrors.163.com/fedora/releases/34

PREFIX=$(df -h /boot/|grep dev|awk '{print $6}')
wget -O ${PREFIX}/vmlinuz ${MIRROR_PREFIX}/Everything/x86_64/os/isolinux/vmlinuz
wget -O ${PREFIX}/initrd.img ${MIRROR_PREFIX}/Everything/x86_64/os/isolinux/initrd.img

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
linux${EFI} /vmlinuz ip=dhcp inst.text inst.vnc inst.vncpassword=PaFfW0rd inst.repo=${MIRROR_PREFIX}/Everything/x86_64/os inst.ks=http://www.timectrl.net/files/fedora-kickstart-cn.txt
initrd${EFI} /initrd.img
}
ENDL

grub-set-default Installer || true
sed -i -e 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=Installer/g' /etc/default/grub

update-grub
find /boot -name grub.cfg |xargs -i grub2-mkconfig -o {}


