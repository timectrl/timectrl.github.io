#!/bin/bash
set -x


sudo dnf -y install screen bash-completion
sudo dnf -y install vim openssl less sqlite tree
sudo dnf -y install tar gzip bzip2 xz zip unzip unrar p7zip
sudo dnf -y install wget curl telnet ftp mtr rsync tcpdump iproute
sudo dnf -y install wireguard-tools openvpn

sudo dnf -y install make gcc patch diffutils automake libtool pkgconf-pkg-config
sudo dnf -y install kernel-devel libcurl-devel openssl-devel
sudo dnf -y install git subversion
sudo dnf -y install golang
sudo dnf -y install mariadb


#sudo dnf -y install code
