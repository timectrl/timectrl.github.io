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


# proton hosts
sed -i '$a\\n11.2.5.251  proton.jikedata.com\n' /etc/hosts


# minio
wget -O /usr/local/bin/mc https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x /usr/local/bin/mc


# wxMSG
cat > /etc/wxMSG.ini <<ENDL
http_proxy=http://11.2.4.1:8080
ENDL


# proton
sed -i -e 's/HTTP_PROXY.*$/HTTP_PROXY=http:\/\/11.2.4.1:8080/g' /etc/proton/proton.ini
rm -fr /etc/proton/serverId
rm -fr /etc/sudoers.d/zhangquan


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
ExecStop=/bin/kill -9 \${MAINPID}

[Install]
WantedBy=multi-user.target
ENDL
systemctl enable PrometheusNodeExporter
#wget https://github.com/prometheus/node_exporter/releases/download/v1.8.1/node_exporter-1.8.1.linux-amd64.tar.gz


# Set limits for work user
cat >/etc/security/limits.d/90-work.conf <<ENDL
work    hard    nofile           9999999
work    soft    nofile           9999999
ENDL


# set iptables notrack
cat >>/etc/rc.local <<ENDL
for port in 80 443 21980
do
	iptables -t raw -A PREROUTING -p tcp --dport \$port -j NOTRACK
	iptables -t raw -A OUTPUT -p tcp --sport \$port -j NOTRACK
done

sysctl net.ipv4.tcp_fin_timeout=3
#sysctl net.ipv4.tcp_tw_recycle=1
sysctl net.ipv4.tcp_tw_reuse=1
sysctl net.ipv4.tcp_max_syn_backlog=5120
sysctl net.ipv4.tcp_syn_retries=3
sysctl net.ipv4.tcp_synack_retries=3
sysctl net.ipv4.tcp_max_syn_backlog=65536
sysctl net.core.wmem_max=8388608
sysctl net.core.rmem_max=8388608
sysctl net.core.somaxconn=4094
sysctl net.core.optmem_max=81920
sysctl net.ipv4.tcp_syncookies=0

ENDL


# clean dnf
dnf -y update
dnf -y install net-tools lrzsz crontabs
dnf clean all


# clean USER
sed -i '/zhangquan/d' /etc/passwd /etc/shadow /etc/group /etc/subuid /etc/subgid /etc/gshadow
rm -fr /etc/passwd- /etc/shadow- /etc/group- /etc/subuid- /etc/subgid- /etc/gshadow-
rm -fr /home/zhangquan
rm -fr /home/USER


# clean log
find /var/log -type f |xargs rm -fr
find /var/spool/mail -type f |xargs rm -fr
journalctl --rotate
journalctl --vacuum-time=1s
journalctl --vacuum-size=1K --vacuum-files=1
journalctl --vacuum-files=1
journalctl --vacuum-time=1s --vacuum-size=1K --vacuum-files=1
journalctl --update-catalog


exit 

