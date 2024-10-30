#!/bin/bash
if [ $UID -ne 0 ]
then
	echo "root user only"
	exit 1
fi

set -x


apt-get -y install screen bash-completion
apt-get -y install vim openssl less sqlite3 tree
apt-get -y install tar gzip bzip2 xz-utils zip unzip unrar-free p7zip
apt-get -y install wget curl telnet ftp mtr rsync tcpdump iproute2
apt-get -y install wireguard-tools openvpn

apt-get -y install make gcc patch diffutils automake libtool pkgconf
apt-get -y install linux-headers-$(uname -r) libcurl4-openssl-dev libssl-dev
apt-get -y install git subversion
apt-get -y install golang
apt-get -y install mariadb-client

