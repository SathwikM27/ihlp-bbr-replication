#!/bin/bash

#sourced from https://github.com/google/bbr/blob/master/Documentation/bbr-quick-start.md
sudo apt-get update
sudo apt-get build-dep linux
sudo apt-get upgrade

# Make /usr/src writeable/sticky like /tmp:
cd /usr/src && sudo chmod 1777 .
# Clone a copy of the kernel sources:
git clone git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git
cd /usr/src/net-next

#configure kernel

cd /usr/src/net-next
make prepare
make -j`nproc`
make -j`nproc` modules

#install and reboot
cd /usr/src/net-next
sudo make -j`nproc` modules_install install
sudo bash -c 'echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf'
sudo bash -c 'echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf'
sudo reboot now


