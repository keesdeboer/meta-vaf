#config files are loaded before FILESEXTRAPATH can be used as prepend.
FILESPATH_prepend := "${THISDIR}/linux-mainline-3.8/files:"

SRC_URI =+ "file://defconfig"

PRINC := "${@int(PRINC) + 1}"
