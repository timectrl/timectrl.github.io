#!/bin/bash
if [ $UID -ne 0 ]
then
	echo "root user only"
	exit 1
fi

set -x


# chrony time proxy
sed -i -e 's/^pool/#pool/g' /etc/chrony.conf
sed -i '/#pool/apool 11.2.4.1 iburst' /etc/chrony.conf


# dnf proxy
sed -i '$a\\nproxy=http://11.2.4.1:8080\n' /etc/dnf/dnf.conf


# minio
wget -O /usr/local/bin/mc https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x /usr/local/bin/mc


# wxMSG
cat > /etc/wxMSG.ini <<ENDL
http_proxy=http://11.2.4.1:8080
ENDL


# proton
sed -i -e '/^HTTP_PROXY.*$/HTTP_PROXY=http:\/\/11.2.4.1:8080/g' /etc/proton/proton.ini
rm -fr /etc/proton/serverId


# root bash_history
ln -s -f /dev/null /root/.bash_history


# Prometheus Node Exporter
cat >/lib/systemd/system/PrometheusNodeExporter.service <<ENDL
[Unit]
Description=Prometheus Node Export
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/node_exporter
ExecStop=/bin/kill -9 ${MAINPID}

[Install]
WantedBy=multi-user.target
ENDL
systemctl enable PrometheusNodeExporter
#wget https://github.com/prometheus/node_exporter/releases/download/v1.5.0/node_exporter-1.5.0.linux-amd64.tar.gz



# clean dnf
dnf -y update
dnf clean all


# clean USER
rm -fr /home/USER


# clean log
find /var/log -type f |xargs rm -fr


