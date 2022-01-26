#!/bin/sh

if [ -f /sys/firmware/efi/runtime ]
then
	mkdir -p /target/boot/efi/EFI/boot
	cp /target/boot/efi/EFI/debian/grubx64.efi /target/boot/efi/EFI/boot/bootx64.efi
	#in-target bash -c '( echo "grub-efi-amd64 grub2/force_efi_extra_removable boolean true" | debconf-set-selections; )'
	echo "grub-efi-amd64 grub2/force_efi_extra_removable boolean true" | in-target debconf-set-selections
fi


exit 0

