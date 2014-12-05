Author: C.S. Kwekkeboom
Date: November 2014

###################################################################################################
History
###################################################################################################

This buildsystem is based on the angstrom setup scripts provided by https://github.com/angstrom-distribution/setup-scripts/
The choice has been made to use the v2012.12-yocto1.3 branch, because in the previous flasher image (preinstalled in the early beaglebone blacks in the beginning of the PEM3 project) is based on this branch. Using a newer branch results in using newer versions of certain libraries (e.g. libc), which in my case caused memory corruption running a precompiled version (SPU v0.3.7) of the SPU3 firmware.

###################################################################################################
How is this environment created?
###################################################################################################

1 $git clone https://github.com/angstrom-distribution/setup-scripts/
2 $git checkout remotes/origin/angstrom-v2012.12-yocto1.3
3 $git checkout -b addlayer
4 Write meta-vaf layer in a seperate git repository
5 Add meta-vaf layer to conf/bblayers.conf and commit changes to addlayer branch
6 Build u-boot-vaf
7 Build console-image-vaf
8 Build flasher-image-vaf
9 Run script to run 3.14 kernel: ./build_kernel.sh
10 Use the deploy script to create a flasher sd card image

See the file installed_packages for an overview of my machine configuration

###################################################################################################
How to use
###################################################################################################
$MACHINE=beaglebone ./oebb.sh config beaglebone

To start a build of the kernel, source the environment file and do:
$. ~/.oe/environment-angstromv2012.12
$bitbake virtual/kernel

To build u-boot
$bitbake u-boot-vaf

Make sure the MD5SUM for u-boot and MLO match:
$md5sum build/tmp-angstrom_v2013_06-eglibc/deploy/images/beaglebone/MLO
$md5sum build/tmp-angstrom_v2013_06-eglibc/deploy/images/beaglebone/u-boot.img
$grep "MD5" sources/meta-vaf/meta-pem3/recipes-pem3/pem3-flasher-scripts/pem3-flasher-scripts/emmc.sh
Verify the checksums match!!!!

To build the deployment image:
$bitbake console-image-vaf

To build the flasher image:
$bitbake flasher-image-vaf

To build custom kernel (3.14.25 with VAF defconfig)
$./build_kernel.sh

Prepare an sd card with two partitions
$./deploy.sh -p /dev/sd[x] 

Deploy the image to a micro-SD card (drive x) using
$./deploy.sh -c /dev/sd[x] 

Extract an .img file from the sd card for further deployment. Use fdisk to determine the size of the partitions
$sudo fdisk /dev/sdd
$p
Find last block of the second partition (in my case 273104)
$dd if=/dev/sdd of=flasher_image.img bs=512 count=273104

Extra:
$git pull
$./oebb.sh update

###################################################################################################
How to fetch sources for offline usage
###################################################################################################

bitbake -c fetchall u-boot-vaf
bitbake -c fetchall gcc-linaro-4.7
bitbake -c fetchall chatter-sender

#bitbake -c fetchall virtual/kernel
#bitbake -c fetchall console-image-vaf
#bitbake -c fetchall flasher-image-vaf
#bitbake -c fetchall meta-ros

Add BB_NO_NETWORK = "1" to local.conf
Remove meta-ros layer from layers.conf

bitbake u-boot-vaf
bitbake virtual/kernel
bitbake console-image-vaf
bitbake flasher-image-vaf

########################################################################
Tricks:
########################################################################
Really rebuild (sometimes build does not incorporate file changes)
$bitbake -c cleansstate <recipe>
$bitbake -f -c compile <recipe>
$bitbake <recipe>



###################################################################################################
Changelog
###################################################################################################

1. Added console-image-vaf.bb and flasher-image-vaf.bb to recipes-images (see https://github.com/kkwekkeboom/meta-vaf/tree/csk_layer/recipes-images/angstrom)
2. Added custom kernel defconfig to recipes-kernel (see https://github.com/kkwekkeboom/meta-vaf/tree/csk_layer/recipes-kernel/linux)
3. Added recipes-pem3: (see https://github.com/kkwekkeboom/meta-vaf/tree/csk_layer)
	3-1. Changed /etc/fstab in base-files (see https://github.com/kkwekkeboom/meta-vaf/tree/csk_layer/recipes-pem3/base-files)
	3-2. Include libmodbus with custom RTU path in image (see https://github.com/kkwekkeboom/meta-vaf/tree/csk_layer/recipes-pem3/libmodbus and https://github.com/kkwekkeboom/libmodbus/tree/rtupatch)
	3-3. Added flasher-scripts: eMMc partition / format and eMMc populate script (see https://github.com/kkwekkeboom/meta-vaf/tree/csk_layer/recipes-pem3/pem3-flasher-scripts)
	3-4. Added pem3-scripts: pem3 service, dns service, software update scripts, software update udev rules, device tree (see https://github.com/kkwekkeboom/meta-vaf/tree/csk_layer/recipes-pem3/pem3-scripts)
4. Added u-boot with patch to set bootdelay to zero (see https://github.com/kkwekkeboom/u-boot-vaf/tree/bootdelay_patches)
	

###################################################################################################
Tested:
###################################################################################################
V-pem3_0.3.8 runs
V-Added /application and /database  and /database/log directories to deployment image
V-pem3.service
V-sdcard.rules
V-usbstick.rules
V-handle_storagedevice.sh
V-software-update.sh
V-static_network.service -> Replaced by /etc/init.d/network restart
V-install libmodbus automatically
V-set password during build
V-modify 55-resolv.conf script to put nameservers on /database partition -> not needed
V-create necessary files for dns settings (/etc/zone /etc/hostname /etc/
V-usb ethernet works
V-kernel option WATCHDOG_NOWAYOUT=y enabled
V-Full eMMc used for /database
V-flashen / software update via sdcard / usb mogelijk
V-versienummber
V-u-boot integreren in build
V-Ethernet bug fixed by upgrading to kernel version 3.14.25-ti-r37 (ifdown ifup cycling works now) 
#TODO:
#-create .img
#-add beaglebone serial port drivers for windows to BBB?


