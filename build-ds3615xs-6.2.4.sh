#!/bin/bash

# prepare build tools
sudo apt-get update && sudo apt-get install --yes --no-install-recommends ca-certificates build-essential git libssl-dev curl cpio bspatch vim gettext bc bison flex dosfstools kmod jq

root=`pwd`
mkdir DS3615xs-6.2.4
mkdir output
cd DS3615xs-6.2.4

# download redpill
git clone --depth=1 https://github.com/RedPill-TTG/redpill-lkm.git
git clone --depth=1 https://github.com/RedPill-TTG/redpill-load.git

# download syno linux kernel
curl --location "https://sourceforge.net/projects/dsgpl/files/Synology%20NAS%20GPL%20Source/25426branch/bromolow-source/linux-3.10.x.txz/download" --output linux-3.10.x.txz

# build redpill-lkm
cd redpill-lkm
tar -xf ../linux-3.10.x.txz
cd linux-3.10*
linuxsrc=`pwd`
cp synoconfigs/bromolow .config
sed -i 's/   -std=gnu89/   -std=gnu89 -fno-pie/' Makefile
make oldconfig ; make modules_prepare
cd ..
make LINUX_SRC=${linuxsrc}
read -a KVERS <<< "$(sudo modinfo --field=vermagic redpill.ko)" && cp -fv redpill.ko ../redpill-load/ext/rp-lkm/redpill-linux-v${KVERS[0]}.ko || exit 1
cd ..

# build redpill-load
cd redpill-load
cp -f ${root}/user_config.DS3615xs.json ./user_config.json
sudo ./build-loader.sh 'DS3615xs' '6.2.4-25556'
mv images/redpill-DS3615xs_6.2.4-25556*.img ${root}/output/
cd ${root}
