#Angstrom image to test systemd

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/LICENSE;md5=3f40d7994397109285ec7b81fdeb3b58"

IMAGE_PREPROCESS_COMMAND = "rootfs_update_timestamp"

DISTRO_UPDATE_ALTERNATIVES ??= ""
#ROOTFS_PKGMANAGE_PKGS ?= '${@base_conditional("ONLINE_PACKAGE_MANAGEMENT", "none", "", "${ROOTFS_PKGMANAGE} ${DISTRO_UPDATE_ALTERNATIVES}", d)}'

CONMANPKGS ?= "connman connman-angstrom-settings connman-plugin-loopback connman-plugin-ethernet connman-plugin-wifi connman-systemd"
CONMANPKGS_libc-uclibc = ""

EXTRA_MACHINE_IMAGE_INSTALL_ti33x = "gadget-init"

IMAGE_INSTALL += " \
	angstrom-packagegroup-boot \
	dropbear \
	bash \
	timestamp-service \
	packagegroup-basic \
	${CONMANPKGS} \
	gadget-init \
	kernel-modules \
	kernel-module-gadgetfs \
	kernel-module-g-mass-storage \
	kernel-module-g-serial \ 
	kernel-module-g-ether \
	usbinit \
"
#	kernel-module-g-file-storage \
#	
#	kernel-modules dtc \
#RDEPENDS += " \
	#kernel-module-hci-usb \
#	kernel-module-hci-uart \
	#"
BAD_RECOMMENDATIONS = "avahi-daemon avahi-autoipd"



IMAGE_DEV_MANAGER   = "udev"
IMAGE_INIT_MANAGER  = "systemd"
IMAGE_INITSCRIPTS   = " "
IMAGE_LOGIN_MANAGER = "tinylogin shadow"

export IMAGE_BASENAME = "console-image-vaf-base"

inherit image
