#Angstrom image to test systemd

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/LICENSE;md5=3f40d7994397109285ec7b81fdeb3b58"

IMAGE_PREPROCESS_COMMAND = "rootfs_update_timestamp"

DISTRO_UPDATE_ALTERNATIVES ??= ""
#ROOTFS_PKGMANAGE_PKGS ?= '${@base_conditional("ONLINE_PACKAGE_MANAGEMENT", "none", "", "${ROOTFS_PKGMANAGE} ${DISTRO_UPDATE_ALTERNATIVES}", d)}'

CONMANPKGS ?= "connman connman-angstrom-settings connman-plugin-loopback connman-plugin-ethernet connman-plugin-wifi connman-systemd connman-tests"
CONMANPKGS_libc-uclibc = ""

EXTRA_MACHINE_IMAGE_INSTALL ?= ""
EXTRA_MACHINE_IMAGE_INSTALL_ti33x = "gadget-init"

IMAGE_INSTALL += " \
	angstrom-packagegroup-boot \
	dropbear \
	bash \
	timestamp-service \
	packagegroup-basic \
	kernel-modules dtc \
	gadget-init \
	usbutils \
	${EXTRA_MACHINE_IMAGE_INSTALL} \
"
#${CONMANPKGS} \
#		usbinit \ -> interferes with gadget-init
#	kernel-module-g-ether \ -> interferes with gadget-init
#	kernel-module-g-serial \ -> redundant with gadget-init

BAD_RECOMMENDATIONS = "avahi-daemon avahi-autoipd"



IMAGE_DEV_MANAGER   = "udev"
IMAGE_INIT_MANAGER  = "systemd"
IMAGE_INITSCRIPTS   = " "
IMAGE_LOGIN_MANAGER = "tinylogin shadow"

export IMAGE_BASENAME = "console-image-vaf-base"

inherit image
