#!/bin/bash

# Exit on first error
set -e

# Debug
# echo "Env: $(env)"
# echo "Cmdline: $(cat /proc/cmdline)"

rm -f ${WORKDIR}/.exit_code

save_and_shutdown() {
    # Default exit code
    if [ ! -f ${WORKDIR}/.exit_code ]; then
	echo 42 > ${WORKDIR}/.exit_code
    fi

    # save built for host result
    # force clean shutdown
    set +e
    echo KILLING
    kill -9 $(jobs -p)
    halt -f
}

# make sure we shut down cleanly
trap save_and_shutdown EXIT SIGINT SIGTERM

# go back to where we were invoked
cd $WORKDIR

# configure path to include /usr/local
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# can't do much without proc!
mount -t proc none /proc

# pseudo-terminal devices
mkdir -p /dev/pts
mount -t devpts none /dev/pts

# shared memory a good idea
mkdir -p /dev/shm
mount -t tmpfs none /dev/shm

# sysfs a good idea
mount -t sysfs none /sys

# pidfiles and such like
mkdir -p /var/run
mount -t tmpfs none /var/run

# takes the pain out of cgroups
cgroups-mount

# mount /var/lib/docker with a tmpfs
#mount -t tmpfs none /var/lib/docker
chmod -R 1777 /var/lib/docker

# enable ipv4 forwarding for docker
echo 1 > /proc/sys/net/ipv4/ip_forward


# configure networking
ip addr add 127.0.0.1 dev lo
ip link set lo up
ip addr add 10.1.1.1/24 dev eth0
ip link set eth0 up
ip route add default via 10.1.1.254


# configure dns (google public)
mkdir -p /run/resolvconf
echo 'nameserver 8.8.8.8' > /run/resolvconf/resolv.conf
mount --bind /run/resolvconf/resolv.conf /etc/resolv.conf


# Start docker daemon
docker -d &
while ! [ -e /var/run/docker.sock ]; do sleep 0.1; done


# Print docker version
docker info
docker version


# Call command
command=$(cat ${WORKDIR}/.command)
set +e
/bin/bash -ce "${command}"
echo $? > ${WORKDIR}/.exit_code

