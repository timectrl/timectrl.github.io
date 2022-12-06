#!/bin/bash
if [ $UID -ne 0 ]
then
	echo "root user only"
	exit 1
fi

set -x

# virtio
cat >> /etc/initramfs-tools/modules <<ENDL
virtio_blk
virtio_scsi
virtio_net
virtio_pci
virtio_ring
virtio
ENDL
update-initramfs -u
# lsinitramfs /boot/initrd.img-`uname -r` |grep virtio


