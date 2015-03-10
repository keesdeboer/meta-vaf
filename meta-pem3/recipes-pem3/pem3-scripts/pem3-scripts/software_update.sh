#!/bin/bash
#@author: 			C.S. Kwekkeboom
#@description: 	Script to perform a software upgrade
#@parameters:		$1: a firmware file path (e.g. /tmp/sda1/pem3_0.3.8.tar.xz)

FIRMWARE_SOURCE=$1
FIRMWARE_DESTINATION=$2
FIRMWARE_LOG="/database/firmware_log.txt"
RETVAL=0
#stop application

if [ -e "/lib/systemd/system/pem3.service" ]; then
	systemctl stop pem3.service
fi
#erase partition
mount -o remount,rw /dev/mmcblk0p2	

#############create new application

#install new application
mkdir -p $FIRMWARE_DESTINATION
tar -xJf $FIRMWARE_SOURCE -C $FIRMWARE_DESTINATION

#############verify application
if [ -e "$FIRMWARE_DESTINATION/checksum.md5" ]; then
	cd $FIRMWARE_DESTINATION
	MD5ERROR=$(md5sum -c checksum.md5 | grep FAILED)
else 
	MD5ERROR="Checksum does not exist"
fi
if [ -z "$MD5ERROR" ]; then
	OLD_VERSION=$(readlink /application/pem3)
	NEW_VERSION=$(cat $FIRMWARE_DESTINATION/version.txt)
	#switch to new firmware
	if [ -e /application/pem3 ]; then
		rm /application/pem3
	fi
	ln -sf $FIRMWARE_DESTINATION /application/pem3
	systemctl start pem3.service
	if [ -n "$OLD_VERSION" ]; then
		if [ "$OLD_VERSION" != "$FIRMWARE_DESTINATION" ]; then
			rm -r $OLD_VERSION
		fi
	fi
	echo "Software updated from $OLD_VERSION to $NEW_VERSION" >> $FIRMWARE_LOG
else
	RETVAL=1
	rm -r $FIRMWARE_DESTINATION
	echo "New firmware md5sum failed $MD5ERROR" >> $FIRMWARE_LOG
fi

#remount
sync
sleep 2
mount -o remount,ro /dev/mmcblk0p2
exit $RETVAL
