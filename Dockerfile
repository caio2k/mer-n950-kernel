
FROM caio2k/mer-n950:latest
MAINTAINER caio2k

WORKDIR /srv/mer/targets/n950rootfs/root
#RUN /root/./sb2_wrapper.exp 'zypper in perl ncurses-devel'
RUN git clone https://github.com/caio2k/kernel-adaptation-n950-n9.git
#RUN git clone https://github.com/caio2k/kernel-plus-harmattan.git
sb2 make n9_mer_defconfig
sb2 make -j4 zImage
sb2 make -j4 modules
sb2 make modules_install INSTALL_MOD_PATH=./mods


