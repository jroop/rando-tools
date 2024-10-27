#!/bin/bash

STEP=$1

if [[ "${STEP}" == "make-secrets" ]]; then
  cp config/secrets.sh.sh secrets.sh
  echo "go ahead and edit ./secrets.sh"
  exit 0
fi

if [[ ! -f "./secrets.sh" ]]; then
  echo -e "run:\n\t$0 make-secrets"
  exit 0
fi

# the generated and edited file that has all config info
source ./secrets.sh

# get the base file name without compressed extension .xz

RPI_IMAGE=$(basename ${RPI_IMAGE_LINK} .xz)
echo -e "using image: ${RPI_IMAGE}"

# find OS base 32 vs 64
export RPI_OS=
# arm64
if [[ "${RPI_IMAGE}" == *"arm64"* ]]; then
  # used on file names
  RPI_OS=_64
fi

# show all the variables
export -p | grep RPI_

# get an image want to use from here: https://www.raspberrypi.com/software/operating-systems/#raspberry-pi-os-32-bit
# see if download and the image doesn't already exists
if [[ "${STEP}" == "download" && ! -f "${RPI_IMAGE}" ]]; then
  # download and decompress it
  wget -O ${RPI_IMAGE}.xz ${RPI_IMAGE_LINK} && xz -d ${RPI_IMAGE}.xz
  exit 0
fi

if [[ "${STEP}" == "see-card" ]]; then 
  lsblk -p | grep /dev/sd
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
    echo "sudo dd if=${RPI_IMAGE} of=${2} bs=4M conv=fsync status=progress"
  else  
    echo "need to pass card mount like /dev/sdb or /dev/sda"
  fi
  exit 0
fi

if [[ "${STEP}" == "build" ]]; then

  echo -e "if want to disable WIFI or BT then secrets.sh NETWORK_TYPE=eth0 default wlan0"

  mkdir -p tmp/bootfs && mkdir -p tmp/rootfs

  # password for pi
  if [[ "${2}" ]]; then
    export RPI_ENCRYPT_PASSWD=${2}
  else
    echo -e "pass in encrypted password from running\n echo 'my_secret_password' | openssl passwd -6 -stdin"
    exit 1
  fi

  # bootfs pi encrypt password
  envsubst < config/bootfs/userconf.txt.sh > tmp/bootfs/userconf.txt

  # bootfs files ssh and wifi
  envsubst < config/bootfs/ssh > tmp/bootfs/ssh
  envsubst < config/bootfs/wpa_supplicant.conf.sh > tmp/bootfs/wpa_supplicant.conf

  # bootfs files config (might now work on newer congfigs)
  envsubst < config/bootfs/config${RPI_OS}.txt.sh > tmp/bootfs/config.txt

  # rootfs files host names
  envsubst < config/rootfs/hostname.sh > tmp/rootfs/hostname
  envsubst < config/rootfs/hosts.sh > tmp/rootfs/hosts

  # rootfs files on for older OS
  if [[ ! "${RPI_OS}" == "_64" ]]; then
    envsubst < config/rootfs/dhcpcd.conf.sh > tmp/rootfs/dhcpcd.conf
  fi

  echo "check files under: tmp/bootfs & tmp/rootfs"

  exit 0
fi

if [[ "${STEP}" == "update-files" ]]; then

  if [[ ! -d "${RPI_SDCARD_MNT_BOOTFS}" || ! -d "${RPI_SDCARD_MNT_ROOTFS}" ]]; then
    echo "make sure RPI_SDCARD_MNT_BOOTFS & RPI_SDCARD_MNT_ROOTFS are set in secrets.sh"
    echo "make sure SD card is mounted ... click in folder"
    exit 1
  fi

  # bootfs files copy
  sudo cp tmp/bootfs/userconf.txt ${RPI_SDCARD_MNT_BOOTFS}/
  sudo cp tmp/bootfs/ssh ${RPI_SDCARD_MNT_BOOTFS}/
  sudo cp tmp/bootfs/wpa_supplicant.conf ${RPI_SDCARD_MNT_BOOTFS}/

  # rootfs files copy
  sudo cp tmp/rootfs/hostname ${RPI_SDCARD_MNT_ROOTFS}/etc/
  sudo cp tmp/rootfs/hosts ${RPI_SDCARD_MNT_ROOTFS}/etc/
  
  # if want to set static with specific dhcp server
  if [[ ! -z "${RPI_STATIC_IP}" ]]; then 
    sudo cp tmp/bootfs/config.txt ${RPI_SDCARD_MNT_BOOTFS}/
    sudo cp tmp/rootfs/dhcpcd.conf ${RPI_SDCARD_MNT_ROOTFS}/etc/
  fi

  echo -e "try to unmount:\n\t${RPI_SDCARD_MNT_BOOTFS}\n\t${RPI_SDCARD_MNT_ROOTFS}"

  exit 0
fi
