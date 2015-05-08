#!/bin/bash
#by caio2k

#Parameters
GITHUB_REPO_OWNER=$1
GITHUB_REPO_NAME=$2
KERNEL_CONFIG=$3

#cloning kernel image
git clone "git://github.com/${GITHUB_REPO_OWNER}/${GITHUB_REPO_NAME}.git"

#compiling kernel
cd "${GITHUB_REPO_NAME}"
sb2 make "${KERNEL_CONFIG}"
sb2 make -j4 zImage
sb2 make -j4 modules
sb2 make modules_install INSTALL_MOD_PATH=./mods

#copying it to binpaste
####TODO

