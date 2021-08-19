#!/bin/bash

# prepare build tools
sudo apt-get update && sudo apt-get install --yes --no-install-recommends ca-certificates build-essential git libssl-dev curl cpio bspatch vim gettext bc bison flex dosfstools kmod jq

# download syno toolkit
curl --location "https://sourceforge.net/projects/dsgpl/files/toolkit/DSM7.0/ds.apollolake-7.0.dev.txz/download" --output ds.apollolake-7.0.dev.txz

tar -xf ds.apollolake-7.0.dev.txz usr/local/x86_64-pc-linux-gnu/x86_64-pc-linux-gnu/sys-root/usr/lib/modules/DSM-7.0/build

# build redpill-lkm
cd redpill-lkm
make LINUX_SRC=../usr/local/x86_64-pc-linux-gnu/x86_64-pc-linux-gnu/sys-root/usr/lib/modules/DSM-7.0/build
cd ..
read -a KVERS <<< "$(sudo modinfo --field=vermagic redpill-lkm/redpill.ko)" && cp -fv redpill-lkm/redpill.ko redpill-load/ext/rp-lkm/redpill-linux-v${KVERS[0]}.ko || exit 1

# build redpill-load
cp user_config.json redpill-load/
cd redpill-load
./build-loader.sh 'DS918+' '7.0-41890'
cd images
tar -cJf redpill-DS918+_7.0-41890.img.txz redpill-DS918+_7.0-41890*.img
