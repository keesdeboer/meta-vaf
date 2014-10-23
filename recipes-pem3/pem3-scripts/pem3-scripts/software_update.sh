#!/bin/bash
#SD card layout
SD_DEVICE="/dev/mmcblk1p1" #device triggering the /etc/udev/rules.d/sdcard.rules
USB_DEVICE="/dev/sd*1" #device triggering /etc/udev/rules.d/usb.rules
SD_DIR="/tmp/sdcard" #mount point
USB_DIR="/tmp/usbstick" #mount point usb
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
	mkdir -p $SD_DIR/old_settings$DATETIME
	cp /database/database.csv $SD_DIR/old_settings$DATETIME/
	cp -r /database/log $SD_DIR/old_settings$DATETIME/
	cp $FIRMWARE_LOG $SD_DIR/old_settings$DATETIME/
	sync
}

function backup_firmware_log() {
	cp $FIRMWARE_LOG $SD_DIR/old_settings$DATETIME/
	sync
}

function update_settings() {
	NEW_SETTINGS=$(find "${SD_DIR}/settings" -name ${SETTINGS_FILE} | head -1)
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
}

function check_firmware_version() {
	OLD_VERSION=0
	NEW_VERSION=0
	NEW_FIRMWARE=$(find "${SD_DIR}/firmware" -name ${FIRMWARE_FILE} | head -1)
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

function upgrade_firmware() {
	#stop application
	
	if [ -e "/lib/systemd/system/pem3.service" ]; then
		systemctl stop pem3.service
	fi
	#erase partition
	mount -o remount,rw /dev/mmcblk0p3	
	
#############create new application
	
	#install new application
	mkdir -p /application/pem3_$NEW_VERSION
	tar -xJf $NEW_FIRMWARE -C /application/pem3_$NEW_VERSION
	
#############verify application
	if [ -e "/application/pem3_$NEW_VERSION/checksum.md5" ]; then
		cd /application/pem3_$NEW_VERSION
		MD5ERROR=$(md5sum -c checksum.md5 | grep FAILED)
	else 
		MD5ERROR="Checksum does not exist"
	fi
	if [ -z "$MD5ERROR" ]; then
		OLD_VERSION=$(readlink /application/pem3)
		#switch to new firmware
		rm /application/pem3
		ln -sf /application/pem3_$NEW_VERSION /application/pem3
		systemctl start pem3.service
		if [ -n "$OLD_VERSION" ]; then
			if [ "$OLD_VERSION" != "/application/pem3_$NEW_VERSION" ]; then
				rm -r $OLD_VERSION
			fi
		fi
		echo "Software update complete" >> $FIRMWARE_LOG
		UPDATED_FIRMWARE=true
	else
		ERROR="${ERROR}, $MD5ERROR"
		rm -r /application/pem3_$NEW_VERSION
		echo "New firmware md5sum failed $MD5ERROR" >> $FIRMWARE_LOG
	fi
	
	#remount
	sync
	sleep 2
	mount -o remount,ro /dev/mmcblk0p3
}

now=$(date +"%m/%d/%Y %H:%M:%S")
if [ -b $SD_DEVICE ]; then
	#mount	
	echo "$now found sd card" >> $FIRMWARE_LOG
	mkdir -p ${SD_DIR}
	mount ${SD_DEVICE} ${SD_DIR} -o noatime
	
	backup_settings
	
	#find new software	
	if [ -e "${SD_DIR}/firmware" ]; then
		echo "update-firmware"
		check_firmware_version
		if [ "$result" == "true" ]; then
			echo "Upgrading software from (v$OLD_VERSION) to (v$NEW_VERSION)" >> $FIRMWARE_LOG
			upgrade_firmware
		else
			echo "Software provided (v$NEW_VERSION) is not newer than current (v$OLD_VERSION)" >> $FIRMWARE_LOG
		fi
	fi	
	
	#find new settings
	if [ -e "${SD_DIR}/settings" ]; then
		echo "update-settings"
		update_settings
	fi

	#copy update log to SD card
	backup_firmware_log
	sleep 3
	sync
	umount ${SD_DEVICE}
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
