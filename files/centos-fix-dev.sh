#!/bin/bash
if [ $UID -ne 0 ]
then
	echo "root user only"
	exit 1
fi

set -x


dnf -y install epel-release
dnf -y install screen bash-completion
dnf -y install vim openssl less sqlite tree
dnf -y install tar gzip bzip2 xz zip unzip unrar p7zip
dnf -y install wget curl telnet ftp mtr rsync tcpdump iproute
dnf -y install wireguard-tools openvpn

dnf -y install make gcc patch diffutils automake libtool pkgconf-pkg-config
dnf -y install kernel-devel libcurl-devel openssl-devel
dnf -y install git subversion
dnf -y install golang
dnf -y install mariadb

