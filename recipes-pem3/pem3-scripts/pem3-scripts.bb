DESCRIPTION = "Scripts and services to make the pem3 firmware working"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/LICENSE;md5=3f40d7994397109285ec7b81fdeb3b58"

inherit systemd

SRC_URI = "file://pem3.service \
					 file://dns_update.service \
           file://sdcard.rules \
           file://software_update.sh \
					 file://am335x-bone.dtb \
					 file://am335x-boneblack.dtb \
					"

do_install() {
	install -d ${D}${base_libdir}/systemd/system
	install -m 0644 ${WORKDIR}/*.service ${D}${base_libdir}/systemd/system

	install -d ${D}${sysconfdir}/udev/rules.d
	install -m 0644 ${WORKDIR}/*.rules ${D}${sysconfdir}/udev/rules.d

	install -d ${D}${bindir}
	install -m 0755 ${WORKDIR}/*.sh ${D}${bindir}

	#overwrite udhcpc default script, and chance location of /etc/resolv.conf
#	install -d ${D}${sysconfdir}/udhcpc.d
 # install -m 0755 ${WORKDIR}/50default ${D}${sysconfdir}/udhcpc.d/
	
	install -d ${D}/application
	install -d ${D}/database
	install -d ${D}/boot
	
	install -m 0755 ${WORKDIR}/am335x-bone.dtb ${D}/boot
	install -m 0755 ${WORKDIR}/am335x-boneblack.dtb ${D}/boot
}

#NATIVE_SYSTEMD_SUPPORT = "1"
SYSTEMD_PACKAGES = "${PN}-systemd"
SYSTEMD_SERVICE = "pem3.service dns_update.service"
SYSTEMD_AUTO_ENABLE = "enable"

FILES_${PN} = "${base_libdir}/systemd/system/pem3.service \
							 ${base_libdir}/systemd/system/dns_update.service \
							 ${base_libdir}/systemd/system/emmc.service \
               ${bindir}/software_update.sh \
               ${sysconfdir}/udev/rules.d/sdcard.rules \
							 /boot/am335x-bone.dtb \
							 /boot/am335x-boneblack.dtb \
							 /application \
							 /database \
							 /boot \
              "
FILES_${PN}-systemd += "${systemd_unitdir}/system/"

RPROVIDES = "pem3-scripts"

