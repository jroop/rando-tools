#!/bin/bash

STEP=$1
IMAGE=2021-10-30-raspios-bullseye-armhf-lite

# get an image want to use from here: https://www.raspberrypi.com/software/operating-systems/#raspberry-pi-os-32-bit
if [[ "${STEP}" == "download" ]]; then
  wget -O raspios-lite.zip https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-11-08/${IMAGE}.zip && unzip raspios-lite.zip
  exit 0
fi

if [[ "${STEP}" == "see-card" ]]; then 
  lsblk -p
  if [[ "${2}" ]]; then
    # unmount cards
    echo "${1}, ${2}"
    umount ${2}1
    umount ${2}2

    echo "done trying to umount ${2}*"
  fi
  exit 0
fi


if [[ "${STEP}" == "copy" ]]; then
  echo "see here: https://www.raspberrypi.com/documentation/computers/getting-started.html"
  if [[ "${2}" ]]; then
    echo "sudo dd if=${IMAGE}.img of=${2} bs=4M conv=fsync status=progress"
  else  
    echo "need to pass card mount like /dev/sdb"
  fi
  exit 0
fi

if [[ "${STEP}" == "build" ]]; then

  echo -e "if want to disable WIFI or BT then add following lines to /boot/config.txt\n\tdtoverlay=disable-wifi\n\tdtoverlay=disable-bt"

  # if no secrets.sh make it and exit
  if [[ ! -f "./secrets.sh" ]]; then
    cp config/secrets.sh.tpl secrets.sh
    echo "after editing ./secrets.sh run again"
    exit 0
  fi

  source secrets.sh

  mkdir -p tmp/boot && mkdir -p tmp/rootfs

  # boot files
  envsubst < config/boot/ssh > tmp/boot/ssh
  envsubst < config/boot/wpa_supplicant.conf.tpl > tmp/boot/wpa_supplicant.conf
  envsubst < config/boot/config.txt.tpl > tmp/boot/config.txt

  # rootfs files
  envsubst < config/rootfs/hostname.tpl > tmp/rootfs/hostname
  envsubst < config/rootfs/hosts.tpl > tmp/rootfs/hosts
  envsubst < config/rootfs/dhcpcd.conf.tpl > tmp/rootfs/dhcpcd.conf

  echo "check files under: tmp/boot & tmp/rootfs"

  exit 0
fi

if [[ "${STEP}" == "copy-files" ]]; then

  source secrets.sh

  if [[ ! -d "${SDCARD_MNT_BOOT}" || ! -d "${SDCARD_MNT_ROOTFS}" ]]; then
    echo "make sure SDCARD_MNT_BOOT & SDCARD_MNT_ROOTFS are set in secrets.sh"
    echo "make sure SD card is mounted ... click in folder"
    exit 1
  fi

  # boot files copy
  cp tmp/boot/ssh ${SDCARD_MNT_BOOT}/
  cp tmp/boot/wpa_supplicant.conf ${SDCARD_MNT_BOOT}/
  cp tmp/boot/config.txt ${SDCARD_MNT_BOOT}/

  # rootfs files copy
  sudo cp tmp/rootfs/hostname ${SDCARD_MNT_ROOTFS}/etc/
  sudo cp tmp/rootfs/hosts ${SDCARD_MNT_ROOTFS}/etc/
  sudo cp tmp/rootfs/dhcpcd.conf ${SDCARD_MNT_ROOTFS}/etc/

  echo -e "try to unmount:\n\t${SDCARD_MNT_BOOT}\n\t${SDCARD_MNT_ROOTFS}"

  exit 0
fi

# for dnsmasq

# /etc/hosts
# 127.0.0.1	localhost
# ::1		localhost ip6-localhost ip6-loopback
# ff02::1		ip6-allnodes
# ff02::2		ip6-allrouters

# 127.0.1.1	rpi-001
# # my entries
# 192.168.1.7	upwall
# 192.168.1.9	garage
# 192.168.1.10	upstairs
# 192.168.1.20	nas


# cat /etc/dnsmasq.d/home.lan 
# domain-needed
# bogus-priv
# strict-order
# expand-hosts
# domain=home.lan
