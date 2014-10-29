#! /bin/sh
# mkcard.sh v0.5
# (c) Copyright 2009 Graeme Gregory <dp@xora.org.uk>
# (c) Copyright 2013 Koen Kooi <koen@dominion.thruhere.net>
# Changed by Kees Kwekkeboom <ckwekkeboom@vaf.nl>:
# -added 2 application-specific partitions
# Licensed under terms of GPLv2
#
# Parts of the procudure base on the work of Denys Dmytriyenko
# http://wiki.omap.com/index.php/MMC_Boot_Format

export LC_ALL=C

if [ $# -ne 1 ]; then
	echo "Usage: $0 <drive>"
	exit 1;
fi

DRIVE=$1

dd if=/dev/zero of=$DRIVE bs=1M count=1

SIZE=`fdisk -l $DRIVE | grep Disk | grep bytes | awk '{print $5}'`

echo DISK SIZE - $SIZE bytes

CYLINDERS=`echo $SIZE/255/63/512 | bc`
 
echo CYLINDERS - $CYLINDERS
#divide the 233 cilinders
{
echo ,9,0x0C,*
echo ,50,,-
echo ,,,-
} | sfdisk -D -H 255 -S 63 -C $CYLINDERS $DRIVE

sleep 1


if [ -x `which kpartx` ]; then
	kpartx -a -v ${DRIVE}
fi

# handle various device names.
# note something like fdisk -l /dev/loop0 | egrep -E '^/dev' | cut -d' ' -f1 
# won't work due to https://bugzilla.redhat.com/show_bug.cgi?id=649572

PARTITION1=${DRIVE}1
if [ ! -b ${PARTITION1} ]; then
	PARTITION1=${DRIVE}p1
fi

DRIVE_NAME=`basename $DRIVE`
DEV_DIR=`dirname $DRIVE`

if [ ! -b ${PARTITION1} ]; then
	PARTITION1=$DEV_DIR/mapper/${DRIVE_NAME}p1
fi

PARTITION2=${DRIVE}2
if [ ! -b ${PARTITION2} ]; then
	PARTITION2=${DRIVE}p2
fi
if [ ! -b ${PARTITION2} ]; then
	PARTITION2=$DEV_DIR/mapper/${DRIVE_NAME}p2
fi

PARTITION3=${DRIVE}3
if [ ! -b ${PARTITION3} ]; then
	PARTITION3=${DRIVE}p3
fi
if [ ! -b ${PARTITION3} ]; then
	PARTITION3=$DEV_DIR/mapper/${DRIVE_NAME}p3
fi

#PARTITION4=${DRIVE}4
#if [ ! -b ${PARTITION4} ]; then
	#PARTITION4=${DRIVE}p4
#fi
#if [ ! -b ${PARTITION4} ]; then
#	PARTITION4=$DEV_DIR/mapper/${DRIVE_NAME}p4
#fi

# now make partitions.
if [ -b ${PARTITION1} ]; then
	umount ${PARTITION1}
	mkfs.vfat -F 32 -n "BEAGLEBONE" ${PARTITION1}
else
	echo "Cant find boot partition in /dev"
fi

#Kees Kwekkeboom: Angstrom read-only partition, thus journalling disabled
if [ -b ${PARITION2} ]; then
	umount ${PARTITION2}
	mkfs.ext2 -L "Angstrom" ${PARTITION2} 
else
	echo "Cant find rootfs partition in /dev"
fi

#Kees Kwekkeboom: create additional partition for the PEM3 application which will become read-only. Therefore journalling disabled
if [ -b ${PARITION3} ]; then
	umount ${PARTITION3}
	mkfs.ext4 -L "Database" ${PARTITION3}
else
	echo "Cant find application partition in /dev"
fi

#Kees Kwekkeboom: create additional partition for the PEM3 database. RW partition, thus journalling is more robust
#if [ -b ${PARITION4} ]; then
#	umount ${PARTITION4}
#	mkfs.ext4  -L "Storage" ${PARTITION4} 
#else
#	echo "Cant find storage partition in /dev"
#fi

if [ -x `which kpartx` ]; then
	kpartx -d -v ${DRIVE}
fi
