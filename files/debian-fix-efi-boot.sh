#!/bin/sh

# in-target bash -c '( echo "grub-efi-amd64 grub2/force_efi_extra_removable boolean true" | debconf-set-selections; )'

if [ -f /sys/firmware/efi/runtime ]
then
	chroot /target mkdir -p /boot/efi/EFI/boot
	chroot /target cp /boot/efi/EFI/debian/grubx64.efi /boot/efi/EFI/boot/bootx64.efi
	chroot /target sh -c 'echo "grub-efi-amd64 grub2/force_efi_extra_removable boolean true" | debconf-set-selections'
fi


exit 0

