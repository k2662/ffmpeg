#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs

# load functions
. $1/functions.sh

# load version
VERSION=$(cat "$1/../version/vpx")
checkStatus $? "load version failed"
echo "version: $VERSION"

# start in working directory
cd "$2"
checkStatus $? "change directory failed"
mkdir "vpx"
checkStatus $? "create directory failed"
cd "vpx/"
checkStatus $? "change directory failed"

# download source
curl -o vpx.tar.gz -L https://github.com/webmproject/libvpx/archive/v$VERSION.tar.gz
checkStatus $? "download of vpx failed"

# unpack
tar -zxf "vpx.tar.gz"
checkStatus $? "unpack vpx failed"
cd "libvpx-$VERSION/"
checkStatus $? "change directory failed"

# prepare build
./configure --prefix="$3" --disable-unit-tests
checkStatus $? "configuration of vpx failed"

# build
make -j $4
checkStatus $? "build of vpx failed"

# install
make install
checkStatus $? "installation of vpx failed"
