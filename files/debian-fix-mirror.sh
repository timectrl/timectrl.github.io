#!/bin/sh

if [ $UID -ne 0 ]
then
	echo "root user only"
	exit 1
fi

set -x

MIRROR=cdn-aws.deb.debian.org

sed -i "s@/deb.debian.org/@/${MIRROR}/@g"      /etc/apt/sources.list ; \
sed -i "s@/ftp.debian.org/@/${MIRROR}/@g"      /etc/apt/sources.list ; \
sed -i "s@/security.debian.org/@/${MIRROR}/@g" /etc/apt/sources.list ; \

