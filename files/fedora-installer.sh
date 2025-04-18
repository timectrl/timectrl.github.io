#!/bin/bash
if [ $UID -ne 0 ]
then
	echo "root user only"
	exit 1
fi

set -x

VER=42

#MIRROR_PREFIX="https://dl.fedoraproject.org/pub/fedora/linux/releases/${VER}" # 官方
MIRROR_PREFIX="https://download.fedoraproject.org/pub/fedora/linux/releases/${VER}" # mirror redirect
#MIRROR_PREFIX="http://mirrors.tuna.tsinghua.edu.cn/fedora/releases/${VER}" # 清华大学
#MIRROR_PREFIX="http://mirrors.ustc.edu.cn/fedora/releases/${VER}" # 中国科学技术大学
#MIRROR_PREFIX="http://mirror.sjtu.edu.cn/fedora/linux/releases/${VER}" # 上海交通大学
#MIRROR_PREFIX="http://mirror.nju.edu.cn/fedora/releases/${VER}" # 南京大学
#MIRROR_PREFIX="http://mirror.lzu.edu.cn/fedora/releases/${VER}" # 兰州大学
#MIRROR_PREFIX="http://mirrors.163.com/fedora/releases/${VER}" # 163
#MIRROR_PREFIX="http://mirrors.cloud.tencent.com/fedora/releases/${VER}" # 腾讯云
#MIRROR_PREFIX="http://mirrors.aliyun.com/fedora/releases/${VER}" # 阿里云
#MIRROR_PREFIX="http://mirrors.huaweicloud.com/fedora/releases/${VER}" # 华为云
#MIRROR_PREFIX="http://repo.huaweicloud.com/fedora/releases/${VER}" # 华为云

ROOT_PREFIX=$(df -h /boot/|grep dev|head -n 1|awk '{print $6}')
ROOT_DEVICE=$(df -h /boot/|grep dev|head -n 1|awk '{print $1}')
ROOT_UUID=$(blkid ${ROOT_DEVICE}|sed -e 's/ /\n/g'|grep ^UUID|sed -e 's/^[^"]*"\?//g' -e 's/"\?[^"]*$//g')
wget -c -O ${ROOT_PREFIX}/vmlinuz ${MIRROR_PREFIX}/Everything/x86_64/os/images/pxeboot/vmlinuz
wget -c -O ${ROOT_PREFIX}/initrd.img ${MIRROR_PREFIX}/Everything/x86_64/os/images/pxeboot/initrd.img
wget -c -O ${ROOT_PREFIX}/fedora-kickstart.txt   http://www.timectrl.net/files/fedora-kickstart.txt
wget -c -O ${ROOT_PREFIX}/fedora-kickstart-x.txt http://www.timectrl.net/files/fedora-kickstart-x.txt
#mkdir -p ${ROOT_PREFIX}/images
#wget -c -O ${ROOT_PREFIX}/images/install.img ${MIRROR_PREFIX}/Everything/x86_64/os/images/install.img

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

linux${EFI} /vmlinuz ip=dhcp inst.repo=${MIRROR_PREFIX}/Everything/x86_64/os inst.ks=http://www.timectrl.net/files/fedora-kickstart.txt inst.vnc inst.vncpassword=PaFfW0rd
#linux${EFI} /vmlinuz ip=dhcp inst.repo=${MIRROR_PREFIX}/Everything/x86_64/os inst.ks=http://www.timectrl.net/files/fedora-kickstart.txt inst.vnc inst.vncpassword=PaFfW0rd
#linux${EFI} /vmlinuz ip=dhcp inst.repo=${MIRROR_PREFIX}/Everything/x86_64/os inst.ks=hd:${ROOT_DEVICE}:/fedora-kickstart.txt inst.vnc inst.vncpassword=PaFfW0rd
#linux${EFI} /vmlinuz ip=dhcp inst.repo=hd:${ROOT_DEVICE}:/ inst.ks=hd:${ROOT_DEVICE}:/fedora-kickstart.txt inst.vnc inst.vncpassword=PaFfW0rd
#linux${EFI} /vmlinuz ip=dhcp inst.repo=${MIRROR_PREFIX}/Everything/x86_64/os inst.ks=hd:UUID=${ROOT_UUID}:/fedora-kickstart.txt inst.vnc inst.vncpassword=PaFfW0rd
#linux${EFI} /vmlinuz ip=dhcp inst.repo=hd:UUID=${ROOT_UUID}:/ inst.ks=hd:UUID=${ROOT_UUID}:/fedora-kickstart.txt inst.vnc inst.vncpassword=PaFfW0rd

initrd${EFI} /initrd.img
}

menuentry "Installer +X -VNC" {

#set root=(hd0,3)
#set root=(hd0,$(df -h /boot | grep '/dev' | awk '{print $1}'|grep -Eo '[0-9]+'))
search --no-floppy --fs-uuid --set ${ROOT_UUID}

linux${EFI} /vmlinuz ip=dhcp inst.repo=${MIRROR_PREFIX}/Everything/x86_64/os inst.ks=http://www.timectrl.net/files/fedora-kickstart-x.txt
#linux${EFI} /vmlinuz ip=dhcp inst.repo=${MIRROR_PREFIX}/Everything/x86_64/os inst.ks=http://www.timectrl.net/files/fedora-kickstart-x.txt
#linux${EFI} /vmlinuz ip=dhcp inst.repo=${MIRROR_PREFIX}/Everything/x86_64/os inst.ks=hd:${ROOT_DEVICE}:/fedora-kickstart-x.txt
#linux${EFI} /vmlinuz ip=dhcp inst.repo=hd:${ROOT_DEVICE}:/ inst.ks=hd:${ROOT_DEVICE}:/fedora-kickstart-x.txt
#linux${EFI} /vmlinuz ip=dhcp inst.repo=${MIRROR_PREFIX}/Everything/x86_64/os inst.ks=hd:UUID=${ROOT_UUID}:/fedora-kickstart-x.txt
#linux${EFI} /vmlinuz ip=dhcp inst.repo=hd:UUID=${ROOT_UUID}:/ inst.ks=hd:UUID=${ROOT_UUID}:/fedora-kickstart-x.txt

initrd${EFI} /initrd.img
}
ENDL

grub-set-default Installer || true
sed -i -e 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=Installer/g' /etc/default/grub

update-grub
find /boot -name grub.cfg |xargs -i grub2-mkconfig -o {}


