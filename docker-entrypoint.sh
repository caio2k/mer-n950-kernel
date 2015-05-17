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

#cloning kernel image
git clone "git://github.com/${GITHUB_REPO_OWNER}/${GITHUB_REPO_NAME}.git"

#compiling kernel
cd "${GITHUB_REPO_NAME}"
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
tar jcvf "/tmp/$FILE" *

if [ -z "$BINTRAY_APIKEY" ]; then
  echo "build done but it will not be uploaded to bintray due to missing APIKEY"
  exit
fi

#copying it to binpaste
BINTRAY_REPO_DESC="https://github.com/${GITHUB_REPO_OWNER}/${GITHUB_REPO_NAME}/README.md"
BINTRAY_REPO_VERSION=${KERNEL_VERSION}

HEADER1="X-Bintray-Package: $BINTRAY_REPO_PACKAGE"
HEADER2="X-Bintray-Version: $BINTRAY_REPO_VERSION"
HEADER3="X-Bintray-Publish: 1"
HEADER4="X-Bintray-Override: 1"
HEADER5="X-Bintray-Explode: 0"

#check if repository exists
[ `curl -sw "%{http_code}" -o /dev/null -X GET -u"$BINTRAY_USER:$BINTRAY_APIKEY" -H "$HEADER1" -H "$HEADER2" -H "$HEADER3" -H "$HEADER4" -H "$HEADER5" https://api.bintray.com/repos/$BINTRAY_REPO_OWNER/$BINTRAY_REPO_NAME` -eq 200 ] || exit 1

#check if package already exists
if [ `curl -sw "%{http_code}" -o /dev/null -u"$BINTRAY_USER:$BINTRAY_APIKEY" -X GET "https://api.bintray.com/packages/$BINTRAY_REPO_OWNER/$BINTRAY_REPO_NAME/$BINTRAY_REPO_PACKAGE"` -ne 200 ]; then
  #if package doesn't exists, try to create it
  echo "Creating package $BINTRAY_REPO_PACKAGE"
  JSON_CREATE_PACKAGE="{ \"name\": \"$BINTRAY_REPO_PACKAGE\", \"desc\": \"auto\", \"desc_url\": \"$BINTRAY_REPO_DESC\", \"labels\": \"\", \"licenses\": [\"GPL-2.0\"], \"vcs_url\": \"kernel.org\" }"
  curl -sw "%{http_code}" -o /dev/null -u"$BINTRAY_USER:$BINTRAY_APIKEY" -H "Content-Type: application/json" -X POST "https://api.bintray.com/packages/$BINTRAY_REPO_OWNER/$BINTRAY_REPO_NAME" --data "$JSON_CREATE_PACKAGE"
fi

#upload file
cd /tmp
curl -vvf -T $FILE -u"$BINTRAY_USER:$BINTRAY_APIKEY" -H "$HEADER1" -H "$HEADER2" -H "$HEADER3" -H "$HEADER4" -H "$HEADER5" https://api.bintray.com/content/$BINTRAY_REPO_OWNER/$BINTRAY_REPO_NAME/kernel/$BINTRAY_REPO_PACKAGE/

