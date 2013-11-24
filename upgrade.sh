#!/bin/bash -e
# Installer script for makemkv - installs build dependencies, downloads source, 
# compiles it, and then installs it.

function usage(){
    echo "Usage: $0 <version>"
    echo "E.g. $0 1.7.0"
}

if [ ${#@} -eq 0 ]
then
    usage
    exit 0
fi

VERSION=$1; shift;

if [ ${#@} -gt 0 ]
then
    echo "ERROR: Extra arguments found after version number '${VERSION}': ${@}"  >&2
    usage
    exit 1
fi

function download_sources(){
    # $1: undecorated version number, e.g. "1.8.6"
    VERSION=$1;
    for FILE in makemkv-bin-${VERSION}.tar.gz makemkv-oss-${VERSION}.tar.gz
    do
        if [ -e ${FILE} ]
        then
            echo "File already downloaded: ${FILE}" >&2
            continue
        else
            echo "Fetching ${FILE}"
            wget --progress=dot "http://www.makemkv.com/download/${FILE}"
        fi
    done
}

function install_latest_build_deps(){
    echo "Installing pre-requisites using sudo apt-get line in MakeMKV forum thread"
    $(curl --location 'http://www.makemkv.com/forum2/viewtopic.php?f=3&t=224' | \
        sed -ne '/sudo apt-get/{s/^.*\(sudo apt-get [^<]*\).*$/\1/;p;q0}')
}

function compile(){
    VERSION=$1
    CORE_COUNT=$(grep processor /proc/cpuinfo | wc -l)

    echo "Compiling v${VERSION}"
    for SUFFIX in bin oss
    do
        tar zxvf makemkv-${SUFFIX}-${VERSION}.tar.gz
        pushd makemkv-${SUFFIX}-${VERSION}
        mkdir -p tmp
        echo "accepted" > tmp/eula_accepted
        nice make -j ${CORE_COUNT} -f makefile.linux
        popd
    done
}

function install(){
    VERSION=$1
    echo "Installing v${VERSION}"
    for SUFFIX in bin oss
    do
        pushd makemkv-${SUFFIX}-${VERSION}
        sudo make -f makefile.linux install
        popd
    done
}


install_latest_build_deps
download_sources ${VERSION}
compile ${VERSION}
install ${VERSION}
