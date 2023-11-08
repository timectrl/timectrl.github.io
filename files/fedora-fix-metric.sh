#!/bin/bash
if [ $UID -ne 0 ]
then
	echo "root user only"
	exit 1
fi

set -x

CDIR=/etc/NetworkManager/system-connections/

find ${CDIR} -type f | xargs \
	sed -i '/route-metric/d'
find ${CDIR} -type f | xargs \
	sed -i '/\[ipv/aroute-metric=900'
#find ${CDIR} -type f | xargs \
#	sed -i '/ipv4/aroute-metric=900'
#find ${CDIR} -type f | xargs \
#	sed -i '/ipv6/aroute-metric=900'
