#!/bin/bash
#by caio2k

#Parameters
GITHUB_REPO_OWNER=$1
GITHUB_REPO_NAME=$2
KERNEL_CONFIG=$3

#fixing possible issues with UID/GID in input
if [ -f /input/Makefile ]; then
  TARGET_UID=$(stat -c "%u" /input/Makefile)
  TARGET_GID=$(stat -c "%g" /input/Makefile)
else
  TARGET_UID=0
  TARGET_GID=0
fi

#cloning kernel image if /input is empty 
if [ ! "$(ls -A /input/Makefile)" ]; then
  git clone git://github.com/${GITHUB_REPO_OWNER}/${GITHUB_REPO_NAME}.git /srv/mer/targets/n950rootfs/root/input
else
  cp -r /input /srv/mer/targets/n950rootfs/root/input
fi

#copying kernel source to good destination
cd /srv/mer/targets/n950rootfs/root/input
sb2 make ${KERNEL_CONFIG} || exit 1
KERNEL_VERSION=`sb2 make kernelversion`
export LOCALVERSION="-${GITHUB_REPO_OWNER}"
KERNEL_NAME="${KERNEL_VERSION}-${GITHUB_REPO_OWNER}"
sb2 make -j4 zImage  || exit 2
sb2 make -j4 modules || exit 3
sb2 make modules_install INSTALL_MOD_PATH=./mods || exit 4
mkdir ./mods/boot    || exit 5
cp arch/arm/boot/zImage ./mods/boot/zImage_${KERNEL_NAME} || exit 6

#compressing kernel
FILE="linux_${KERNEL_NAME}.tar.bz2"
cd mods
tar jcvf "/output/$FILE" *
chown ${TARGET_UID}.${TARGET_GID} /output/$FILE

