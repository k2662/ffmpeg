#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs

# load functions
. $1/functions.sh

# load version
VERSION=$(cat "$1/../version/libxml2")
checkStatus $? "load version failed"
echo "version: $VERSION"

# start in working directory
cd "$2"
checkStatus $? "change directory failed"
mkdir "libxml2"
checkStatus $? "create directory failed"
cd "libxml2/"
checkStatus $? "change directory failed"

# download source
curl -O ftp://xmlsoft.org/libxml2/libxml2-$VERSION.tar.gz
checkStatus $? "download of libxml2 failed"

# unpack
tar -zxf "libxml2-$VERSION.tar.gz"
checkStatus $? "unpack libxml2 failed"
cd "libxml2-$VERSION/"
checkStatus $? "change directory failed"

# prepare build
./configure --prefix="$3" --enable-shared=no --without-python
checkStatus $? "configuration of libxml2 failed"

# build
make -j $4
checkStatus $? "build of libxml2 failed"

# install
make install
checkStatus $? "installation of libxml2 failed"
