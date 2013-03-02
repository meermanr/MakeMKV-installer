#!/bin/bash -e

if [ ${#@} -eq 0 ]
then
    echo "Usage: $0 <version>"
    echo "E.g. $0 1.7.0"
    exit 0
fi

for suffix in bin.tar.gz oss.tar.gz
do
    file="makemkv_v${1}_${suffix}"
    if [ -e ${file} ]
    then
        echo "ERROR: File already downloaded: ${file}" >&2
        exit 1
    fi
done

echo "Installing pre-requisites"
sudo apt-get install build-essential libc6-dev libssl-dev libexpat1-dev libgl1-mesa-dev libqt4-dev

echo "Fetching v$1"

wget --progress=dot "http://www.makemkv.com/download/makemkv-bin-${1}.tar.gz" "http://www.makemkv.com/download/makemkv-oss-${1}.tar.gz"

echo "Compiling v$1"
for suffix in bin oss
do
    tar zxvf makemkv-${suffix}-${1}.tar.gz
    pushd makemkv-${suffix}-${1}
    mkdir -p tmp
    echo "accepted" > tmp/eula_accepted
    make -f makefile.linux
    popd
done

echo "Installing v$1"
for suffix in bin oss
do
    pushd makemkv-${suffix}-${1}
    sudo make -f makefile.linux install
    popd
done
