#!/bin/bash
#by caio2k

#Parameters
KERNEL_CONFIG=${1:-rm581_defconfig}
GITHUB_REPO_OWNER=$2
GITHUB_REPO_NAME=$3

FOLDER=`dirname $0`
HEADER="mer-n950-kernel DEBUG"

if [ -f /input/Makefile ]; then
  echo "$HEADER copying kernel source from /input"
  cp -r /input /srv/mer/targets/n950rootfs/root/input
  export LOCALVERSION=""
else
  echo "$HEADER cloning kernel image from github because /input is empty"
  git clone git://github.com/${GITHUB_REPO_OWNER}/${GITHUB_REPO_NAME}.git /srv/mer/targets/n950rootfs/root/input
  export LOCALVERSION="-${GITHUB_REPO_OWNER}"
fi

echo "$HEADER selecting kernel_config ${KERNEL_CONFIG}" 
cd /srv/mer/targets/n950rootfs/root/input
sb2 make ${KERNEL_CONFIG} || exit 1
KERNEL_VERSION=`sb2 make kernelversion`
KERNEL_NAME="${KERNEL_VERSION}${LOCALVERSION}"
echo "$HEADER kernel_version is ${KERNEL_VERSION}"
echo "$HEADER kernel_name is ${KERNEL_NAME}" 

echo "$HEADER compiling kernel zImage" 
sb2 make -j4 zImage

echo "$HEADER compiling kernel modules"
sb2 make -j4 modules || exit 3

echo "$HEADER installing modules in MOCK folder"
sb2 make modules_install INSTALL_MOD_PATH=./mods || exit 4

echo "$HEADER launching prepare_modules.sh script"
${FOLDER}/prepare_modules.sh "${KERNEL_VERSION}" "./mods" || exit 5

echo "$HEADER compressing kernel in tarball"
FILE="linux_${KERNEL_NAME}.tar.bz2"
cd mods
tar jcvf "/output/$FILE" *

TARGET_UID=`stat -c '%u' /output`
TARGET_GID=`stat -c '%g' /output`
echo "$HEADER setting up tarball owner UID/GID ${TARGET_UID}/${TARGET_GID}"
chown ${TARGET_UID}.${TARGET_GID} /output/$FILE

