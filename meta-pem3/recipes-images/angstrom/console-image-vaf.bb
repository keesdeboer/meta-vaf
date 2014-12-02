#Angstrom bootstrap image
require console-image-vaf-base.bb

DEPENDS += "packagegroup-base-extended \
	   "
IMAGE_INSTALL += " \
	packagegroup-base-extended \
	nodejs-dev \
	xz \
	tar \
	libmodbus \
	pem3-scripts \
	bash \
"
ROOTFS_POSTPROCESS_COMMAND += "set_root_passwd;"
ROOTFS_POSTPROCESS_COMMAND += "create_symlinks;"

create_symlinks() {
  #!/bin/sh
  # post installation script
 	ln -sf /database/hostname ${IMAGE_ROOTFS}/etc/hostname
	ln -sf /database/interfaces ${IMAGE_ROOTFS}/etc/network/interfaces
	ln -sf /database/zone	${IMAGE_ROOTFS}/etc/zone
	ln -sf /database/resolv.conf	${IMAGE_ROOTFS}/etc/resolv.conf
}

#created pwd using $openssl passwd -1 -salt xyz  yourpass
set_root_passwd() {
   sed 's%^root:[^:]*:%root:$1$xyz$nZAXjXf7FBNyaMTiMyiNp/:%' \
       < ${IMAGE_ROOTFS}/etc/shadow \
       > ${IMAGE_ROOTFS}/etc/shadow.new;
   mv ${IMAGE_ROOTFS}/etc/shadow.new ${IMAGE_ROOTFS}/etc/shadow ;
}

export IMAGE_BASENAME = "console-image-vaf"
