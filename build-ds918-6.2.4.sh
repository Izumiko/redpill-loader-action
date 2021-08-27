#!/bin/bash

# prepare build tools
sudo apt-get update && sudo apt-get install --yes --no-install-recommends ca-certificates build-essential git libssl-dev curl cpio bspatch vim gettext bc bison flex dosfstools kmod jq

root=`pwd`
mkdir ds918-6.2.4
mkdir output
cd ds918-6.2.4

# download redpill
git clone --depth=1 https://github.com/RedPill-TTG/redpill-lkm.git
git clone --depth=1 https://github.com/RedPill-TTG/redpill-load.git

# download syno linux kernel
curl --location "https://sourceforge.net/projects/dsgpl/files/Synology%20NAS%20GPL%20Source/25426branch/apollolake-source/linux-4.4.x.txz/download" --output linux-4.4.x.txz

# build redpill-lkm
cd redpill-lkm
tar -xf ../linux-4.4.x.txz
cd linux-4.4*
linuxsrc=`pwd`
cp synoconfigs/apollolake .config
echo '+' > .scmversion
make oldconfig ; make modules_prepare
cd ..
make LINUX_SRC=${linuxsrc}
read -a KVERS <<< "$(sudo modinfo --field=vermagic redpill.ko)" && cp -fv redpill.ko ../redpill-load/ext/rp-lkm/redpill-linux-v${KVERS[0]}.ko || exit 1
cd ..

# build redpill-load
cd redpill-load
cp ${root}/user_config.DS918+.json ./user_config.json
sudo ./build-loader.sh 'DS918+' '6.2.4-25556'
mv images/redpill-DS918+_6.2.4-25556*.img ${root}/output/
cd ${root}
