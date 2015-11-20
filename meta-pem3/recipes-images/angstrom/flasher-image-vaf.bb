#Angstrom bootstrap image
require console-image-vaf-base.bb

DEPENDS += "packagegroup-base-extended \
	   "
IMAGE_INSTALL += " \
	packagegroup-base-extended \
	xz \
	bash \
	bc \
	pem3-flasher-scripts \
	libmodbusvaf \
	e2fsprogs-mke2fs \
	dosfstools \
	tar \
"
ROOTFS_POSTPROCESS_COMMAND += "set_root_passwd;"
ROOTFS_POSTPROCESS_COMMAND += "remove_opkg;"

create_symlinks() {
  #!/bin/sh
  # post installation script
 	#ln -sf /database/hostname ${IMAGE_ROOTFS}/etc/hostname
	#ln -sf /database/interfaces ${IMAGE_ROOTFS}/etc/network/interfaces
	#ln -sf /database/zone	${IMAGE_ROOTFS}/etc/zone
	#ln -sf /database/resolv.conf	${IMAGE_ROOTFS}/etc/resolv.conf
}

remove_opkg() {
	rm -r ${IMAGE_ROOTFS}/var/lib/opkg
}

#created pwd using $openssl passwd -1 -salt xyz  yourpass
set_root_passwd() {
   sed 's%^root:[^:]*:%root:$1$xyz$nZAXjXf7FBNyaMTiMyiNp/:%' \
       < ${IMAGE_ROOTFS}/etc/shadow \
       > ${IMAGE_ROOTFS}/etc/shadow.new;
   mv ${IMAGE_ROOTFS}/etc/shadow.new ${IMAGE_ROOTFS}/etc/shadow ;
}

export IMAGE_BASENAME = "flasher-image-vaf"
