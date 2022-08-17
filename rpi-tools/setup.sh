#!/bin/bash

STEP=$1

if [[ "${STEP}" == "make-secrets" ]]; then
  cp config/secrets.sh.tpl secrets.sh
  echo "go ahead and edit ./secrets.sh"
  exit 0
fi

if [[ ! -f "./secrets.sh" ]]; then
  echo -e "run:\n\t$0 make-secrets"
  exit 0
fi

# the generated and edited file that has all config info
source ./secrets.sh

# get an image want to use from here: https://www.raspberrypi.com/software/operating-systems/#raspberry-pi-os-32-bit
if [[ "${STEP}" == "download" ]]; then
  wget -O raspios-lite.zip ${IMAGE_LINK} && unzip raspios-lite.zip
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

  if [[ ! -d "${SDCARD_MNT_BOOT}" || ! -d "${SDCARD_MNT_ROOTFS}" ]]; then
    echo "make sure SDCARD_MNT_BOOT & SDCARD_MNT_ROOTFS are set in secrets.sh"
    echo "make sure SD card is mounted ... click in folder"
    exit 1
  fi

  # boot files copy
  sudo cp tmp/boot/ssh ${SDCARD_MNT_BOOT}/
  sudo cp tmp/boot/wpa_supplicant.conf ${SDCARD_MNT_BOOT}/
  
  # if want to set static with specific dhcp server
  if [[ ! -z "${STATIC_IP}" ]]; then 
    sudo cp tmp/boot/config.txt ${SDCARD_MNT_BOOT}/
    sudo cp tmp/rootfs/hostname ${SDCARD_MNT_ROOTFS}/etc/
    sudo cp tmp/rootfs/hosts ${SDCARD_MNT_ROOTFS}/etc/
    sudo cp tmp/rootfs/dhcpcd.conf ${SDCARD_MNT_ROOTFS}/etc/
  fi

  echo -e "try to unmount:\n\t${SDCARD_MNT_BOOT}\n\t${SDCARD_MNT_ROOTFS}"

  exit 0
fi
