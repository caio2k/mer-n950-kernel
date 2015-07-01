#!/bin/bash
#by caio2k

#Parameters
GITHUB_REPO_OWNER=$1
GITHUB_REPO_NAME=$2
KERNEL_CONFIG=$3
BINTRAY_USER=caio2k
BINTRAY_APIKEY=$4
BINTRAY_REPO_OWNER=caio2k
BINTRAY_REPO_NAME=$2
BINTRAY_REPO_PACKAGE=$1

#cloning kernel image if /input is empty 
if [ ! "$(ls -A /input)" ]; then
  git clone "git://github.com/${GITHUB_REPO_OWNER}/${GITHUB_REPO_NAME}.git" /input
fi

#compiling kernel
cd /input/
sb2 make "${KERNEL_CONFIG}"
KERNEL_VERSION=`sb2 make kernelversion`
export LOCALVERSION="-${GITHUB_REPO_OWNER}"
KERNEL_NAME="${KERNEL_VERSION}-${GITHUB_REPO_OWNER}"
sb2 make -j4 zImage
sb2 make -j4 modules
sb2 make modules_install INSTALL_MOD_PATH=./mods
mkdir ./mods/boot
cp arch/arm/boot/zImage ./mods/boot/zImage_${KERNEL_NAME}

#compressing kernel
FILE="linux_${KERNEL_NAME}.tar.bz2"
cd mods
tar jcvf "/output/$FILE" *

