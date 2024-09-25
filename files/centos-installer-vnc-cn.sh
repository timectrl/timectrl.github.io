#!/bin/bash
if [ $UID -ne 0 ]
then
	echo "root user only"
	exit 1
fi

set -x

VER=9

MIRROR_PREFIX=http://mirror.centos.org/centos/8-stream
MIRROR_PREFIX=https://mirrors.huaweicloud.com/centos/8-stream
MIRROR_PREFIX=https://repo.huaweicloud.com/centos/8-stream
MIRROR_PREFIX=https://mirror.stream.centos.org/9-stream

ROOT_PREFIX=$(df -h /boot/|grep dev|head -n 1|awk '{print $6}')
ROOT_DEVICE=$(df -h /boot/|grep dev|head -n 1|awk '{print $1}')
ROOT_UUID=$(blkid ${ROOT_DEVICE}|sed -e 's/ /\n/g'|grep ^UUID|sed -e 's/^[^"]*"\?//g' -e 's/"\?[^"]*$//g')
#wget -O ${ROOT_PREFIX}/vmlinuz ${MIRROR_PREFIX}/BaseOS/x86_64/os/isolinux/vmlinuz
#wget -O ${ROOT_PREFIX}/initrd.img ${MIRROR_PREFIX}/BaseOS/x86_64/os/isolinux/initrd.img
wget -O ${ROOT_PREFIX}/vmlinuz ${MIRROR_PREFIX}/BaseOS/x86_64/os/images/pxeboot/vmlinuz
wget -O ${ROOT_PREFIX}/initrd.img ${MIRROR_PREFIX}/BaseOS/x86_64/os/images/pxeboot/initrd.img

EFI=""
if [ -f /sys/firmware/efi/runtime ]
then
	EFI="efi"
fi

sed -i '6,$d' /etc/grub.d/40_custom
cat >>/etc/grub.d/40_custom  <<ENDL
menuentry "Installer" {
linux${EFI} /vmlinuz ip=dhcp root=UUID=${ROOT_UUID} inst.repo=${MIRROR_PREFIX}/BaseOS/x86_64/os inst.ks=http://www.timectrl.net/files/centos-kickstart-vnc-cn.txt inst.text inst.vnc inst.vncpassword=PaFfW0rd

#set root=(hd0,3)
#set root=(hd0,$(df -h /boot | grep '/dev' | awk '{print $1}'|grep -Eo '[0-9]+'))
#linux${EFI} /vmlinuz ip=dhcp inst.repo=${MIRROR_PREFIX}/BaseOS/x86_64/os inst.ks=http://www.timectrl.net/files/centos-kickstart-vnc-cn.txt inst.text inst.vnc inst.vncpassword=PaFfW0rd

initrd${EFI} /initrd.img
}
ENDL

grub-set-default Installer || true
sed -i -e 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=Installer/g' /etc/default/grub

update-grub
find /boot -name grub.cfg |xargs -i grub2-mkconfig -o {}


