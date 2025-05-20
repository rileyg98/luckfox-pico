#!/bin/bash

ROOTFS_NAME="rootfs-alpine.tar.gz"
DEVICE_NAME="pico-mini-b"

while getopts ":f:d:" opt; do
  case ${opt} in
    f) ROOTFS_NAME="${OPTARG}" ;;
    d) DEVICE_NAME="${OPTARG}" ;;
    ?)
      echo "Invalid option: -${OPTARG}."
      exit 1
      ;;
  esac
done

DEVICE_ID="6"
# These two are needed for the new SDK
EMMC_ID="0"
BUILDROOT_ID="0"
case $DEVICE_NAME in
  pico-mini-b) DEVICE_ID="6" ;;
  pico-plus) DEVICE_ID="7" ;;
  pico-pro-max) DEVICE_ID="8" ;;
  *)
    echo "Invalid device: ${DEVICE_NAME}."
    exit 1
    ;;
esac

rm -rf sdk/sysdrv/custom_rootfs/
mkdir -p sdk/sysdrv/custom_rootfs/
cp "$ROOTFS_NAME" sdk/sysdrv/custom_rootfs/

cd sdk/tools/linux/toolchain/arm-rockchip830-linux-uclibcgnueabihf/ 
source env_install_toolchain.sh
cd ../../../../
rm -rf .BoardConfig.mk
echo -e "$DEVICE_ID\n$EMMC_ID\n$BUILDROOT_ID" | ./build.sh lunch
echo "export RK_CUSTOM_ROOTFS=../sysdrv/custom_rootfs/$ROOTFS_NAME" >> .BoardConfig.mk
echo "export RK_BOOTARGS_CMA_SIZE=\"1M\"" >> .BoardConfig.mk

# build sysdrv - rootfs
./build.sh uboot
./build.sh kernel
./build.sh driver
./build.sh env
#./build.sh app
# package firmware
./build.sh firmware
./build.sh save

cd ..

rm -rf output
mkdir -p output
cp sdk/output/image/update.img "output/$DEVICE_NAME-sysupgrade.img"
