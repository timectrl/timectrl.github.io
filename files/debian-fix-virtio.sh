#!/bin/sh


sed -i '$s/^.*$/&\n\n\n/g'   /target/etc/initramfs-tools/modules
sed -i '$a# virtio begin'    /target/etc/initramfs-tools/modules
sed -i '$avirtio_blk'        /target/etc/initramfs-tools/modules
sed -i '$avirtio_scsi'       /target/etc/initramfs-tools/modules
sed -i '$avirtio_net'        /target/etc/initramfs-tools/modules
sed -i '$avirtio_pci'        /target/etc/initramfs-tools/modules
sed -i '$avirtio_ring'       /target/etc/initramfs-tools/modules
sed -i '$avirtio'            /target/etc/initramfs-tools/modules
sed -i '$a# virtio end'      /target/etc/initramfs-tools/modules
sed -i '$s/^.*$/&\n\n\n/g'   /target/etc/initramfs-tools/modules

chroot /target update-initramfs -u


exit 0

