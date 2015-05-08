#!/bin/sh

set -e
WORKDIR=$(pwd)
echo "$@" > .command
rm -f .exit_code

(
    set -x
    ./travis-linux \
	quiet \
	mem=2G \
	rootfstype=hostfs rw \
	eth0=slirp,,/usr/bin/slirp-fullbolt \
	init=${WORKDIR}/travis-linux-init.sh \
	WORKDIR=${WORKDIR} HOME=${HOME}
)

exit_code=$(cat .exit_code)
eval exit ${exit_code}

