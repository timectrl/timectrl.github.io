#!/bin/bash
if [ $UID -ne 0 ]
then
	echo "root user only"
	exit 1
fi

set -x

# bluetooth
cat > /etc/dracut.conf.d/bluetooth.conf <<ENDL
#add_drivers+=" bluetooth "
omit_dracutmodules+=" bluetooth "
ENDL
dracut --regenerate-all --force
exit
rpm -qa|grep kernel-core|sed -e 's/kernel-core-//g'|xargs -i dracut -f --kver {} /boot/initramfs-{}.img {}
#rpm -qa|grep kernel-core|sed -e 's/kernel-core-//g'|xargs -i lsinitrd /boot/initramfs-{}.img |grep virtio


