#!/bin/bash
#by caio2k

#Parameters
GITHUB_REPO_OWNER=$1
GITHUB_REPO_NAME=$2
KERNEL_CONFIG=$3

#fixing possible issues with UID/GID in /input
if [ "$(ls -A /input)" ]; then
  TARGET_UID=$(stat -c "%u" /input)
  TARGET_GID=$(stat -c "%g" /input)
else
  TARGET_UID=1000
  TARGET_GID=1000
fi
#groupadd --gid $TARGET_GID worker
#useradd worker --uid $TARGET_UID -g worker

#cloning kernel image if /input is empty 
if [ ! "$(ls -A /input)" ]; then
  #su worker -c "git clone git://github.com/${GITHUB_REPO_OWNER}/${GITHUB_REPO_NAME}.git /input"
  git clone git://github.com/${GITHUB_REPO_OWNER}/${GITHUB_REPO_NAME}.git /input
fi

#compiling kernel
cd /input/
ls -alhtr
#su worker -c "sb2 make ${KERNEL_CONFIG}" || exit 1
chown -R root.root *
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
chown TARGET_UID.TARGET_GID /output/$FILE

