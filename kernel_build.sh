#!/bin/bash

# Get the Linux versions
LINUX_VER=$1

# Dependencies
apt-get update
apt-get install -y git fakeroot build-essential ncurses-dev xz-utils libssl-dev bc liblz4-tool paxctl libelf-dev

# GCC
GCC_VER=$(gcc -dumpversion | cut -c1)
if [[ $GCC_VER != "5" || $GCC_VER != "6" ]]; then
	GCC_VER=$(gcc -dumpversion | cut -c1-3)
fi
apt-get install -y gcc-${GCC_VER}-plugin-dev

# Download Linux source code
mkdir /opt/linux
cd /opt/linux
wget -c https://cdn.kernel.org/pub/linux/kernel/v$(echo $LINUX_VER | cut -c1).x/linux-${LINUX_VER}.tar.xz
tar xvf linux-${LINUX_VER}.tar.xz
cd linux-${LINUX_VER}

# Config
#cp /boot/config-$(uname -r) .config
make menuconfig

# Compilation
make deb-pkg -j $(nproc)

# Installation
cd ..
dpkg -i linux-image-${LINUX_VER}_${LINUX_VER}-1_amd64.deb
dpkg -i linux-headers-${LINUX_VER}_${LINUX_VER}-1_amd64.deb

# Cleanup
rm linux-${LINUX_VER}.tar.xz
rm -r linux-${LINUX_VER}
find . -type f -not -name "*.deb" -delete

# Load the new kernel without reboot
#apt-get install kexec-tools
#systemctl kexec