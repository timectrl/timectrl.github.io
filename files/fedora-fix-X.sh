#!/bin/bash
if [ $UID -ne 0 ]
then
	echo "root user only"
	exit 1
fi

set -x


dnf -y install rdesktop vinagre
dnf -y install gimp
dnf -y install android-tools
dnf -y --allowerasing install ffmpeg mplayer



