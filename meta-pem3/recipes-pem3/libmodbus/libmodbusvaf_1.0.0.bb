SUMMARY = "A Modbus library"
DESCRIPTION = "libmodbus is a C library designed to provide a fast and robust \
implementation of the Modbus protocol. It runs on Linux, Mac OS X, FreeBSD, \
QNX and Windows."
HOMEPAGE = "http://www.libmodbus.org/"
SECTION = "libs"

LICENSE = "LGPLv2.1+"
LIC_FILES_CHKSUM = "file://COPYING.LESSER;md5=4fbd65380cdd255951079008b364516c"

SRC_URI = "https://github.com/kkwekkeboom/libmodbusvaf/archive/v1.0.0.zip"
SRCREV = "e5483044e6539af010afd75f00111a0a5a4233f8"

inherit autotools pkgconfig
SRC_URI[md5sum] = "dd3ea991baebdae08a07c2bcc2bc065b"
SRC_URI[sha256sum] = "5ca48816476c69d05dfe3e5b8ad55d219a5590868097177b1db77515b9fef733"
