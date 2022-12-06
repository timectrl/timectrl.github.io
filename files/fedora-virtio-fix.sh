#!/bin/bash
if [ $UID -ne 0 ]
then
	echo "root user only"
	exit 1
fi

set -x

# virtio
cat > /etc/dracut.conf.d/virtio.conf <<ENDL
add_drivers+=" virtio_blk virtio_scsi virtio_net virtio_pci virtio_ring virtio "
ENDL
rpm -qa|grep kernel-core|sed -e 's/kernel-core-//g'|xargs -i dracut -f --kver {} /boot/initramfs-{}.img {}
# rpm -qa|grep kernel-core|sed -e 's/kernel-core-//g'|xargs -i lsinitrd /boot/initramfs-{}.img |grep virtio


