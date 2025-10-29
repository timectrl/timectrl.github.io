#!/bin/bash
set -x

#systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.targe

#sudo -u gdm dbus-run-session gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0


dbus-run-session gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0
sudo dbus-run-session gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-timeout 0

gsettings set org.gnome.settings-daemon.plugins.power power-button-action 'nothing'
sudo gsettings set org.gnome.settings-daemon.plugins.power power-button-action 'nothing'

gsettings get org.gnome.settings-daemon.plugins.power power-button-action
sudo gsettings get org.gnome.settings-daemon.plugins.power power-button-action


sudo sed -i '/#HandlePowerKey=/aHandlePowerKey=ignore' /usr/lib/systemd/logind.conf
sudo sed -i '/#HandleRebootKey=/aHandleRebootKey=ignore' /usr/lib/systemd/logind.conf
sudo sed -i '/#HandleRebootKeyLongPress=/aHandleRebootKeyLongPress=ignore' /usr/lib/systemd/logind.conf
sudo sed -i '/#HandleSuspendKey=/aHandleSuspendKey=ignore' /usr/lib/systemd/logind.conf
sudo sed -i '/#HandleSuspendKeyLongPress=/aHandleSuspendKeyLongPress=ignore' /usr/lib/systemd/logind.conf
sudo sed -i '/#HandleHibernateKey=/aHandleHibernateKey=ignore' /usr/lib/systemd/logind.conf
sudo sed -i '/#HandleHibernateKeyLongPress=/aHandleHibernateKeyLongPress=ignore' /usr/lib/systemd/logind.conf
sudo sed -i '/#HandleLidSwitch=/aHandleLidSwitch=ignore' /usr/lib/systemd/logind.conf
sudo sed -i '/#HandleLidSwitchExternalPower=/aHandleLidSwitchExternalPower=ignore' /usr/lib/systemd/logind.conf
sudo sed -i '/#HandleLidSwitchDocked=/aHandleLidSwitchDocked=ignore' /usr/lib/systemd/logind.conf
sudo sed -i '/#HandlePowerKey=/aHandlePowerKey=ignore' /usr/lib/systemd/logind.conf
sudo sed -i '/#HandlePowerKey=/aHandlePowerKey=ignore' /usr/lib/systemd/logind.conf
sudo sed -i '/#HandlePowerKey=/aHandlePowerKey=ignore' /usr/lib/systemd/logind.conf

sudo dnf -y install rdesktop vinagre
sudo dnf -y install gimp
sudo dnf -y install android-tools
sudo dnf -y install --allowerasing ffmpeg mplayer



