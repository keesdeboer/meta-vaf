Adding some stuff:
V-pem3_0.3.8 runs
V-changed /etc/fstab file
V-Added /application and /database directories
V-pem3.service ->Install as autostart?
V-sdcard.rules
V-software-update.sh
V-static_network.service -> Replaced by /etc/init.d/network restart
V-install libmodbus automatically
V-set password during build
V-modify 55-resolv.conf script -> not needed
V-create necessary files for dns settings
-usb ethernet -> build kernel together with image
V-add /database/log partition to emmc.sh script in flasher_image
-versienummber
-use full emmc for database
-flashen / software update via usb of usb ethernet

# volatiles in pem3_scripts, what is that
# TODO:
#-provide version check
#-kernel watchdog nowayout meebouwen in yocto/OE (zie defconfig file in deze feed)
#-add sqlite3?
-create .img

