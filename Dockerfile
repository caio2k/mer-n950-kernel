
FROM caio2k/mer-n950:latest
MAINTAINER caio2k

WORKDIR /srv/mer/targets/n950rootfs/root
RUN /root/./sb2_wrapper.exp 'zypper in perl ncurses-devel'

COPY docker-entrypoint.sh /srv/mer/targets/n950rootfs/root/
RUN  chmod +x /srv/mer/targets/n950rootfs/root/docker-entrypoint.sh
ENTRYPOINT ["/srv/mer/targets/n950rootfs/root/docker-entrypoint.sh"]


#RUN git clone git://github.com/nemomobile/kernel-adaptation-n950-n9.git
##RUN git clone git://github.com/caio2k/kernel-plus-harmattan.git
#WORKDIR /srv/mer/targets/n950rootfs/root/kernel-adaptation-n950-n9
#RUN sb2 make n9_mer_defconfig
#RUN sb2 make -j4 zImage
#RUN sb2 make -j4 modules
#RUN sb2 make modules_install INSTALL_MOD_PATH=./mods


