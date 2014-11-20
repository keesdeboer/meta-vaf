#!/bin/bash

# (c) Copyright 2013 Koen Kooi <koen@dominion.thruhere.net>
# Edited by Kees Kwekkeboom <ckwekkeboom@vaf.nl> 
# Licensed under terms of GPLv2

export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin

ANGSTROM_VERSION="angstrom_version=0.1.0"
PART1MOUNT="/media/1"
PART2MOUNT="/media/2"
#add two extra application specificpartitions
PART3MOUNT="/media/3"
#PART4MOUNT="/media/4"
BOOTMOUNT="/media/boot"

HOSTARCH="$(uname -m)"

MLOMD5="5de100a557ee1ddbdc1f38867a61d53c"
UBOOTMD5="54dbaa006545956d838ddd5738be1150"
UIMAGEMD5=""
ANGSTROMMD5=""

blockdev --flushbufs /dev/mmcblk1

echo "Paritioning eMMC"
dd if=/dev/zero of=/dev/mmcblk1 bs=16M count=16
/usr/bin/mkcard.sh /dev/mmcblk1

echo "Mounting partitions"
mkdir -p ${PART1MOUNT}
mkdir -p ${PART2MOUNT}
mkdir -p ${PART3MOUNT}
#mkdir -p ${PART4MOUNT}
mkdir -p ${BOOTMOUNT}
mount /dev/mmcblk1p1 ${PART1MOUNT} -o sync
mount /dev/mmcblk1p2 ${PART2MOUNT} -o async,noatime
mount /dev/mmcblk1p3 ${PART3MOUNT} -o async,noatime
#mount /dev/mmcblk1p4 ${PART4MOUNT} -o async,noatime
mount /dev/mmcblk0p1 ${BOOTMOUNT} -o async,noatime

mkdir -p $PART3MOUNT/log

echo "Copying uImage + MLO + uEnv.txt files"
cp ${BOOTMOUNT}/MLO ${BOOTMOUNT}/uEnv.txt ${BOOTMOUNT}/u-boot.img ${PART1MOUNT}
echo ${ANGSTROM_VERSION} > ${PART1MOUNT}/angstrom_version.txt

sync
blockdev --flushbufs /dev/mmcblk1

#Kees Kwekkeboom: copy Angstrom to partition 2
echo "Extracting rootfs"
if [ -f ${BOOTMOUNT}/linux/console-image*.tar.xz ]; then
	tar -xJf ${BOOTMOUNT}/linux/console-image*.tar.xz -C ${PART2MOUNT} >> /dev/null;
else
	ERROR="${ERROR}, no rootfs found";  
fi

#echo "Copying kernel"
#cp /boot/uImage_vaf ${PART2MOUNT}/boot
#ln -sf uImage_vaf ${PART2MOUNT}/boot/uImage
echo ${ANGSTROM_VERSION} > ${PART2MOUNT}/boot/angstrom_version.txt

echo "Initialize interfaces"
cp /etc/network/interfaces ${PART3MOUNT}

echo "Set default hostname"
echo "SPU3" >> ${PART3MOUNT}/hostname

echo "Set default zone"
echo ".local" >> ${PART3MOUNT}/zone

if [ "${HOSTARCH}" = "armv7l" ] ; then

	echo "Generating machine ID"
	systemd-nspawn -D ${PART2MOUNT} /bin/systemd-machine-id-setup
	chroot ${PART2MOUNT} dropbearkey -t rsa -f /etc/dropbear/dropbear_rsa_host_key
	#echo "Setting timezone to Europe/Paris"
	#systemd-nspawn -D ${PART2MOUNT} /usr/bin/timedatectl set-timezone Europe/Paris

fi

sync
blockdev --flushbufs /dev/mmcblk1

# verification stage

if [ -e ${PART1MOUNT}/angstrom_version.txt ] ; then
	echo "angstrom_version.txt found"
else
	echo "angstrom_version.txt missing - ERROR"
	ERROR="angstrom_version.txt"
fi

if [ "${MLOMD5}" != "$(md5sum ${PART1MOUNT}/MLO | awk '{print $1}')" ] ; then        
	echo "MLO MD5sum failed"       
	ERROR="${ERROR}, MLO"  
fi   
 
if [ "${UBOOTMD5}" != "$(md5sum ${PART1MOUNT}/u-boot.img | awk '{print $1}')" ] ; then
	echo "u-boot MD5sum failed"
	ERROR="${ERROR}, uboot"
fi

umount /dev/mmcblk1p1
umount /dev/mmcblk1p2
umount /dev/mmcblk1p3
#umount /dev/mmcblk1p4

# force writeback of eMMC buffers
dd if=/dev/mmcblk1 of=/dev/null count=100000

if [ -z "$ERROR" ] ; then
	if [ -e /sys/class/leds/beaglebone\:green\:usr0/trigger ] ; then
		echo default-on > /sys/class/leds/beaglebone\:green\:usr0/trigger
		echo default-on > /sys/class/leds/beaglebone\:green\:usr1/trigger
		echo default-on > /sys/class/leds/beaglebone\:green\:usr2/trigger
		echo default-on > /sys/class/leds/beaglebone\:green\:usr3/trigger
	fi
else
	echo "ERRORS found: ${ERROR}"
	if [ -e /sys/class/leds/beaglebone\:green\:usr0/trigger ] ; then
		echo none > /sys/class/leds/beaglebone\:green\:usr0/trigger
		echo none > /sys/class/leds/beaglebone\:green\:usr1/trigger
		echo none > /sys/class/leds/beaglebone\:green\:usr2/trigger
		echo none > /sys/class/leds/beaglebone\:green\:usr3/trigger
	fi
fi

