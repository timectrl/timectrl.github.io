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


sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
#sudo dnf -y install code

sudo tee /etc/yum.repos.d/antigravity.repo << EOL
[antigravity-rpm]
name=Antigravity RPM Repository
baseurl=https://us-central1-yum.pkg.dev/projects/antigravity-auto-updater-dev/antigravity-rpm
enabled=1
gpgcheck=0
EOL
#sudo dnf install antigravity
