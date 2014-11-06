Author: C.S. Kwekkeboom
Date: November 2014

-History
This buildsystem is based on the angstrom setup scripts provided by https://github.com/angstrom-distribution/setup-scripts/
The choice has been made to use the v2012.12-yocto1.3 branch, because in the previous flasher image (preinstalled in the early beaglebone blacks in the beginning of the PEM3 project) is based on this branch.

-How is this build?
1 $git clone https://github.com/angstrom-distribution/setup-scripts/
2 $git checkout remotes/origin/angstrom-v2012.12-yocto1.3
3 $git checkout -b addlayer
4 Write meta-vaf layer in a seperate git repository
5 Commit changes to addlayer branch
6 Build kernel
7 Build console-image-vaf
8 Build flasher-image-vaf
9 Use the deploy script to create a flasher sd card image

See the file installed_packages for an overview of my machine configuration

-Changelog
1. Added console-image-vaf.bb and flasher-image-vaf.bb to recipes-images 
2. Added custom kernel defconfig to recipes-kernel 
3. Added recipes-pem3:
	3-1. Changed /etc/fstab in base-files
	3-2. Include libmodbus with custom RTU path in image
	3-3. Added flasher-scripts: eMMc partition / format and eMMc populate script
	3-4. Added pem3-scripts: pem3 service, dns service, software update scripts, software update udev rules, device tree
	
-Tested:
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
-versienummber
#-provide version check
#TODO:
#-add sqlite3?
#-create .img


-How to use

$MACHINE=beaglebone ./oebb.sh config beaglebone

To start a build of the kernel, source the environment file and do:
$. ~/.oe/environment-angstromv2012.12
$bitbake virtual/kernel

To build the deployment image:
$bitbake console-image-vaf

To build the flasher image:
$bitbake flasher-image-vaf

Prepare an sd card with two partitions
$./deploy.sh -p /dev/sd[x] 

Deploy the image to a micro-SD card (drive x) using
$./deploy.sh -c /dev/sd[x] 

Extract an .img file from the sd card for further deployment
$dd if=/dev/sdd of=flasher_image.img bs=1M count=???

Extra:
$git pull
$./oebb.sh update

