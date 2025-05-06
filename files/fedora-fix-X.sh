#!/bin/bash
if [ $UID -ne 0 ]
then
	echo "root user only"
	exit 1
fi

set -x

#systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.targe

#sudo -u gdm dbus-run-session gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0
dbus-run-session gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0

sed -i '/#HandlePowerKey=/aHandlePowerKey=ignore' /usr/lib/systemd/logind.conf
sed -i '/#HandleRebootKey=/aHandleRebootKey=ignore' /usr/lib/systemd/logind.conf
sed -i '/#HandleRebootKeyLongPress=/aHandleRebootKeyLongPress=ignore' /usr/lib/systemd/logind.conf
sed -i '/#HandleSuspendKey=/aHandleSuspendKey=ignore' /usr/lib/systemd/logind.conf
sed -i '/#HandleSuspendKeyLongPress=/aHandleSuspendKeyLongPress=ignore' /usr/lib/systemd/logind.conf
sed -i '/#HandleHibernateKey=/aHandleHibernateKey=ignore' /usr/lib/systemd/logind.conf
sed -i '/#HandleHibernateKeyLongPress=/aHandleHibernateKeyLongPress=ignore' /usr/lib/systemd/logind.conf
sed -i '/#HandleLidSwitch=/aHandleLidSwitch=ignore' /usr/lib/systemd/logind.conf
sed -i '/#HandleLidSwitchExternalPower=/aHandleLidSwitchExternalPower=ignore' /usr/lib/systemd/logind.conf
sed -i '/#HandleLidSwitchDocked=/aHandleLidSwitchDocked=ignore' /usr/lib/systemd/logind.conf
sed -i '/#HandlePowerKey=/aHandlePowerKey=ignore' /usr/lib/systemd/logind.conf
sed -i '/#HandlePowerKey=/aHandlePowerKey=ignore' /usr/lib/systemd/logind.conf
sed -i '/#HandlePowerKey=/aHandlePowerKey=ignore' /usr/lib/systemd/logind.conf

dnf -y install rdesktop vinagre
dnf -y install gimp
dnf -y install android-tools
dnf -y --allowerasing install ffmpeg mplayer



