FILESEXTRAPATHS := "${THISDIR}/${PN}"

#increase buildnummer of angstrom
PRINC := "${@int(PRINC) + 1}"
