#!/bin/bash
#@author: 			C.S. Kwekkeboom
#@description: 	Script to handle the insertion of memory devices on the beaglebone black
#@parameters:		$1: kernel name of memory device (e.g. /dev/sda*)

#SD card layout
#SD_DEVICE="/dev/mmcblk1p1" #device triggering the /etc/udev/rules.d/sdcard.rules
#USB_DEVICE="/dev/sd*1" #device triggering /etc/udev/rules.d/usb.rules
DEVICE=/dev/$1
MOUNT_DIR="/tmp/$1" #mount point
FIRMWARE_FILE="pem*_[0-9]*.[0-9]*.[0-9]*.tar.xz"
SETTINGS_FILE="settings.csv"

#Device layout
VERSION="/application/pem3/version.txt"
SETTINGS="/database/settings.csv"
FIRMWARE_LOG="/database/firmware_log.txt"

#result
UPDATED_SETTINGS=false
UPDATED_FIRMWARE=false

function backup_settings() {
	DATETIME=$(date +"%Y%m%d%H%M%S")
	mkdir -p $MOUNT_DIR/old_settings$DATETIME
	cp /database/database.csv $MOUNT_DIR/old_settings$DATETIME/
	cp -r /database/log $MOUNT_DIR/old_settings$DATETIME/
	cp $FIRMWARE_LOG $MOUNT_DIR/old_settings$DATETIME/
	sync
}

function backup_firmware_log() {
	cp $FIRMWARE_LOG $MOUNT_DIR/old_settings$DATETIME/
	sync
}

function update_settings() {
	#find new settings
	if [ -e "${MOUNT_DIR}/settings" ]; then
		echo "update-settings"
		NEW_SETTINGS=$(find "${MOUNT_DIR}/settings" -name ${SETTINGS_FILE} | head -1)
		if [ -n "$NEW_SETTINGS" ]; then #found new settings
			echo "found new settings $NEW_SETTINGS" >> $FIRMWARE_LOG
		
			#if settings are to be updated
			if [ -e "$VERSION" ]; then
				cp $NEW_SETTINGS $SETTINGS
				sync
				sleep 3
				systemctl restart pem3.service
				echo "updated settings $SETTINGS" >> $FIRMWARE_LOG 
				UPDATED_SETTINGS=true
			else 
				echo "No firmware found, settings not applied" >> $FIRMWARE_LOG
			fi
		else 
			echo "no settings file found" >> $FIRMWARE_LOG
		fi
	fi
}

function check_firmware_version() {
	OLD_VERSION=0
	NEW_VERSION=0
	NEW_FIRMWARE=$(find "${MOUNT_DIR}/firmware" -name ${FIRMWARE_FILE} | head -1)
	if [ -n "$NEW_FIRMWARE" ]; then
		echo "found new firmware $NEW_FIRMWARE" >> $FIRMWARE_LOG
		
		#split firmware file name by _ and . characters, e.g. pem3_0.0.1.img
		#and calculate the 6 digits version code
		NEW_TYPE=$(echo "$NEW_FIRMWARE" | awk -F [._] {'print $1'}) 
		temp1=$(echo "$NEW_FIRMWARE" | awk -F [._] {'print $2'})
		temp2=$(echo "$NEW_FIRMWARE" | awk -F [._] {'print $3'})
		temp3=$(echo "$NEW_FIRMWARE" | awk -F [._] {'print $4'})
		NEW_VERSION+=$((temp1 * 10000 + temp2 * 100 + temp3))
		NEW_EXTENSION=$(echo "$NEW_FIRMWARE" | awk -F [._] {'print $5'})
	fi
	if [ -e "$VERSION" ]; then	
		OLD_FIRMWARE=$(cat $VERSION)
		temp1=$(echo "$OLD_FIRMWARE" | awk -F [._] {'print $2'})
		temp2=$(echo "$OLD_FIRMWARE" | awk -F [._] {'print $3'})
		temp3=$(echo "$OLD_FIRMWARE" | awk -F [._] {'print $4'})
		OLD_VERSION+=$((temp1 * 10000 + temp2 * 100 + temp3))
		echo "OLD_VERSION = $OLD_VERSION"
	#else no firmware yet
		
	fi	
	if [ "$NEW_VERSION" -gt "$OLD_VERSION" ]; then
		result=true
	else
		result=false
	fi
}

function upgrade_firmware()
{
	#find new software	
	if [ -d "${MOUNT_DIR}/firmware" ]; then
		echo "update-firmware"
		check_firmware_version
		if [ "$result" == "true" ]; then
			echo "Upgrading software from (v$OLD_VERSION) to (v$NEW_VERSION)" >> $FIRMWARE_LOG
			software_update.sh $NEW_FIRMWARE /application/pem3_$NEW_VERSION
		else
			echo "Software provided (v$NEW_VERSION) is not newer than current (v$OLD_VERSION)" >> $FIRMWARE_LOG
		fi
	fi	
}

function mount_device()
{
	echo "$now found storage device $DEVICE" >> $FIRMWARE_LOG
	mkdir -p ${MOUNT_DIR}
	mount ${DEVICE} ${MOUNT_DIR} -o noatime
}

function umount_device()
{
	sleep 3
	sync
	umount ${DEVICE}
}

now=$(date +"%m/%d/%Y %H:%M:%S")
if [ -b $DEVICE ]; then
	mount_device	
	if [  'mountpoint -q ${MOUNT_DIR}' ]; then
		backup_settings
		upgrade_firmware
		update_settings 	
		backup_firmware_log
		umount_device
	fi	
else
	echo "$now sd card contains no mmcblk1p1" >> $FIRMWARE_LOG
	ERROR="${ERROR}, invalid card"
fi

if [ -z "$ERROR" ]; then
	if [ -e /sys/class/leds/beaglebone\:green\:usr0/trigger ]; then
		echo default-on > /sys/class/leds/beaglebone\:green\:usr0/trigger
		echo default-on > /sys/class/leds/beaglebone\:green\:usr1/trigger
		echo default-on > /sys/class/leds/beaglebone\:green\:usr2/trigger
		echo default-on > /sys/class/leds/beaglebone\:green\:usr3/trigger		
		sleep 10
		echo heartbeat > /sys/class/leds/beaglebone\:green\:usr0/trigger
		echo mmc0 > /sys/class/leds/beaglebone\:green\:usr1/trigger
		echo cpu0 > /sys/class/leds/beaglebone\:green\:usr2/trigger
		echo mmc1 > /sys/class/leds/beaglebone\:green\:usr3/trigger
	fi
	
else
	if [ -e /sys/class/leds/beaglebone\:green\:usr0/trigger ]; then
		echo "ERRORS found: ${ERROR}"
		echo none > /sys/class/leds/beaglebone\:green\:usr0/trigger
		echo none > /sys/class/leds/beaglebone\:green\:usr1/trigger
		echo none > /sys/class/leds/beaglebone\:green\:usr2/trigger
		echo none > /sys/class/leds/beaglebone\:green\:usr3/trigger
		sleep 10
		echo heartbeat > /sys/class/leds/beaglebone\:green\:usr0/trigger
		echo mmc0 > /sys/class/leds/beaglebone\:green\:usr1/trigger
		echo cpu0 > /sys/class/leds/beaglebone\:green\:usr2/trigger
		echo mmc1 > /sys/class/leds/beaglebone\:green\:usr3/trigger
	fi
fi
