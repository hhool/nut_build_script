#!/bin/bash
# usage: sudo ./build_nut.sh build_nut
# usage: sudo ./build_nut.sh prepare_env|get_nut|build_nut
# author: hhool
# date: 2023-11-24
# version: 0.1
# script build nut 2.7.4 from source code on ubuntu 22.04 LTS

set -o errexit
set -o nounset
set -o pipefail

# check user is root
if [ "$(id -u)" != "0" ]; then
    echo "Sorry, you are not root."
    echo "Usage: sudo $0 prepare_env|get_nut|build_nut"
    exit 1
fi

# get build_nut.sh path and parent folder as BUILD_NUT_DIR
BUILD_NUT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)" && echo "BUILD_NUT_DIR=$BUILD_NUT_DIR"

# prepare env
prepare_env()
{
    echo "update build env and dependencies" && sudo apt-get update -y \
    && sudo apt-get install -y build-essential vim git curl wget unzip sudo net-tools rpm python2.7 autoconf autogen automake libtool perl pkg-config asciidoc \
    && sudo apt-get install -y libusb-dev libusb-1.0-0-dev libhidapi-dev libudev-dev libncurses5-dev libwrap0-dev libssl-dev libltdl-dev libglib2.0-dev \
    libdbi-dev libpq-dev
}

# check /usr/bin/python being a link to /usr/bin/python2.7
if [ ! -L /usr/bin/python ]; then
    prepare_env
    sudo ln -s /usr/bin/python2.7 /usr/bin/python
fi

# get nut source code and create install dir
get_nut()
{
    sudo mkdir -p ${BUILD_NUT_DIR}/package && cd ${BUILD_NUT_DIR} && git clone https://github.com/hhool/nut.git && \
    cd ${BUILD_NUT_DIR}/nut && git checkout dev_v2.7.4 && sudo ./autogen.sh
}

# build nut source code and make install to package dir
build_nut()
{
    # check ${BUILD_NUT_DIR}/nut being a dir
    if [ ! -d ${BUILD_NUT_DIR}/nut ]; then
        get_nut
    fi

    cd ${BUILD_NUT_DIR}/nut && sudo ./configure CXXFLAGS="--std=c++14" --prefix=/usr  \
    --with-usb --with-snmp --with-cgi && make && make install DESTDIR=`pwd`/../package
}

# check bash param $1 for prepare_env and get_nut or for build_nut or empty param for build_nut
if [ "$1" = "prepare_env" ]; then
    prepare_env
elif [ "$1" = "get_nut" ]; then
    get_nut
elif [ "$1" = "build_nut" ]; then
    build_nut
elif [ -z "$1" ]; then
    build_nut
else
    echo "Usage: $0 prepare_env|get_nut|build_nut"
fi

# end of file

