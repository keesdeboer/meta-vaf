DESCRIPTION = "Scripts and services to make the pem3 firmware working"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/LICENSE;md5=3f40d7994397109285ec7b81fdeb3b58"

inherit systemd

SRC_URI = "file://emmc.sh \
					 file://mkcard.sh \
					 file://emmc.service \
					 file://am335x-bone.dtb \
					 file://am335x-boneblack.dtb \
					 file://uEnv.txt \
					"
# file://console-image-vaf-beaglebone.tar.xz;unpack=0 

do_install() {
	install -d ${D}${base_libdir}/systemd/system
	install -m 0644 ${WORKDIR}/*.service ${D}${base_libdir}/systemd/system

	install -d ${D}${bindir}
	install -m 0755 ${WORKDIR}/*.sh ${D}${bindir}

	install -d ${D}/build
# install does not work (tries to unpack the file)
#	cp ${WORKDIR}/console-image-vaf-beaglebone.tar.xz ${D}/build 
#	chmod 0755 ${D}/build/console-image-vaf-beaglebone.tar.xz
	install -m 0755 ${WORKDIR}/uEnv.txt ${D}/build
	install -m 0755 ${WORKDIR}/am335x-bone.dtb ${D}/build
	install -m 0755 ${WORKDIR}/am335x-boneblack.dtb ${D}/build
}

SYSTEMD_PACKAGES = "${PN}-systemd"
SYSTEMD_SERVICE = "emmc.service"
SYSTEMD_AUTO_ENABLE = "enable"

FILES_${PN} = "${base_libdir}/systemd/system/emmc.service \
               ${bindir}/mkcard.sh \
							 ${bindir}/emmc.sh \
							 /build \
							 /build/am335x-bone.dtb \
							 /build/am335x-boneblack.dtb \
							 /build/uEnv.txt \
              "
FILES_${PN}-systemd += "${systemd_unitdir}/system/"

RPROVIDES = "pem3-flasher-scripts"
