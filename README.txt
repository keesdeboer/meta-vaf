Adding some stuff:
V-changed /etc/fstab file
V-Added /application and /database directories
X-pem3.service ->Install as autostart?
V-sdcard.rules
V-software-update.sh
V-static_network.service -> Replaced by /etc/init.d/network restart
V-install libmodbus automatically
V-set password during build
V-modify 55-resolv.conf script -> not needed
-create necessary files for dns settings
#-usb ethernet

# volatiles in pem3_scripts, what is that
# TODO:
#-versioenummber
#add /database/log partition to emmc.sh script in flasher_image
#kernel rtpatch
#

