#!/bin/bash

# NOTE ensure variables are filled out
export SSID_NAME=
export SSID_PASS=
export STATIC_IP= # can leave blank if not using static ip setup and will skip
export HOSTNAME=raspberrypi
export NETWORK_TYPE=wlan0 # wlan0 or eth0


# find with lsblk -p, https://www.raspberrypi.com/documentation/computers/getting-started.html#installing-images-on-linux
export SDCARD=/dev/sdb

# Raspios image from here: https://www.raspberrypi.com/software/operating-systems/
export IMAGE_LINK=https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2022-01-28/2022-01-28-raspios-bullseye-armhf-lite.zip
# comes from the end of the above link, with no suffix (ie .zip, .img, .xz)
export IMAGE=2022-01-28-raspios-bullseye-armhf-lite

# SD card locations
export SDCARD_MNT_BOOT=/media/${USER}/boot/
export SDCARD_MNT_ROOTFS=/media/${USER}/rootfs/

if [[ "${NETWORK_TYPE}" == "eth0" ]]; then

  # disable wifi & bluetooth in boot/config.txt
  export BOOT_DISABLE_WIFI=dtoverlay=disable-wifi
  export DOOT_DISABLE_BT=dtoverlay=disable-bt

fi

export STATIC_IP_SETUP=
if [[ ! -z "${STATIC_IP}" ]]; then
  export STATIC_IP_SETUP=$(echo -e "interface ${NETWORK_TYPE}\nstatic ip_address=${STATIC_IP}/24\nstatic routers=192.168.1.1\nstatic domain_name_servers=192.168.1.1")
fi