#!/bin/bash
#by caio2k

#Parameters
GITHUB_REPO_OWNER=$1
GITHUB_REPO_NAME=$2
KERNEL_CONFIG=$3

HEADER="mer-n950-kernel DEBUG"

echo "$HEADER getting UID/GID from /input folder"
if [ -f /input/Makefile ]; then
  TARGET_UID=$(stat -c "%u" /input/Makefile)
  TARGET_GID=$(stat -c "%g" /input/Makefile)
else
  TARGET_UID=0
  TARGET_GID=0
fi

if [ ! "$(ls -A /input/Makefile)" ]; then
  echo "$HEADER cloning kernel image if /input is empty "
  git clone git://github.com/${GITHUB_REPO_OWNER}/${GITHUB_REPO_NAME}.git /srv/mer/targets/n950rootfs/root/input
else
  echo "$HEADER copying kernel source from /input"
  cp -r /input /srv/mer/targets/n950rootfs/root/input
fi

echo "$HEADER selecting kernel_config ${KERNEL_CONFIG}" 
cd /srv/mer/targets/n950rootfs/root/input
sb2 make ${KERNEL_CONFIG} || exit 1
KERNEL_VERSION=`sb2 make kernelversion`
export LOCALVERSION="-${GITHUB_REPO_OWNER}"
KERNEL_NAME="${KERNEL_VERSION}-${GITHUB_REPO_OWNER}"

echo "$HEADER compiling kernel zImage" 
sb2 make -j4 zImage

echo "$HEADER compiling kernel modules"
sb2 make -j4 modules || exit 3

echo "$HEADER installing modules in MOCK folder"
sb2 make modules_install INSTALL_MOD_PATH=./mods || exit 4

echo "$HEADER installing zImage in MOCK folder"
mkdir ./mods/boot    || exit 5
ls arch/arm/boot -alhtr
cp arch/arm/boot/zImage ./mods/boot/zImage_${KERNEL_NAME} || exit 6

echo "$HEADER compressing kernel in tarball"
FILE="linux_${KERNEL_NAME}.tar.bz2"
cd mods
tar jcvf "/output/$FILE" *

echo "$HEADER setting up tarball UID/GID as detected in /output"
chown ${TARGET_UID}.${TARGET_GID} /output/$FILE

