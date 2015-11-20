#CONFFILES_${PN} = ""
THISDIR := "${@os.path.dirname(bb.data.getVar('FILE', d, True))}"
FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}-${PV}:"
PRINC := "${@int(PRINC) + 1}"
