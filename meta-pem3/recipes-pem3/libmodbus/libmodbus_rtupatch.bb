SUMMARY = "A Modbus library"
DESCRIPTION = "libmodbus is a C library designed to provide a fast and robust \
implementation of the Modbus protocol. It runs on Linux, Mac OS X, FreeBSD, \
QNX and Windows."
HOMEPAGE = "http://www.libmodbus.org/"
SECTION = "libs"

LICENSE = "LGPLv2.1+"
LIC_FILES_CHKSUM = "file://COPYING.LESSER;md5=4fbd65380cdd255951079008b364516c"

SRC_URI = "https://github.com/kkwekkeboom/libmodbus/archive/rtupatch.zip"
SRCREV = "d5bd3fdfd7d7dbfd80bb4ecb80c278f892bd8cb5"

inherit autotools pkgconfig
SRC_URI[md5sum] = "84f8a2e2c82586905aea4a44a226662c"
SRC_URI[sha256sum] = "52e5cc5aece4b57b46990246a2d93c88b8923c024f76f813b484fba043ca68f2"
