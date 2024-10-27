#!/bin/bash

# NOTE ensure variables are filled out
export RPI_SSID_NAME=
export RPI_SSID_PASS=
export RPI_STATIC_IP= # can leave blank if not using static ip setup and will skip
export RPI_HOSTNAME=
export RPI_NETWORK_TYPE=wlan0 # wlan0 or eth0

# find with lsblk -p, https://www.raspberrypi.com/documentation/computers/getting-started.html#installing-images-on-linux
# make sure to populate with /dev/sda or /dev/sdb etc
export RPI_SDCARD=

# Raspios image from here: 
# https://www.raspberrypi.com/software/operating-systems/
# pick a file with .xz extension
# ex: https://downloads.raspberrypi.com/raspios_lite_arm64/images/raspios_lite_arm64-2024-07-04/2024-07-04-raspios-bookworm-arm64-lite.img.xz
export RPI_IMAGE_LINK=https://downloads.raspberrypi.com/raspios_lite_arm64/images/raspios_lite_arm64-2024-07-04/2024-07-04-raspios-bookworm-arm64-lite.img.xz

# SD card locations
export RPI_SDCARD_MNT_BOOTFS=/media/${USER}/bootfs/
export RPI_SDCARD_MNT_ROOTFS=/media/${USER}/rootfs/

if [[ "${RPI_NETWORK_TYPE}" == "eth0" ]]; then
  # disable wifi & bluetooth in bootfs/config.txt
  export RPI_BOOT_DISABLE_WIFI=dtoverlay=disable-wifi
  export RPI_BOOT_DISABLE_BT=dtoverlay=disable-bt

fi

export RPI_STATIC_IP_SETUP=
if [[ ! -z "${RPI_STATIC_IP}" ]]; then
  export RPI_STATIC_IP_SETUP=$(echo -e "interface ${RPI_NETWORK_TYPE}\nstatic ip_address=${STATIC_IP}/24\nstatic routers=192.168.1.1\nstatic domain_name_servers=192.168.1.1")
fi
