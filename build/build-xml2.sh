#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs
# $5 = libxml2 version

# load functions
. $1/functions.sh

# start in working directory
cd "$2"
checkStatus $? "change directory failed"
mkdir "xml2"
checkStatus $? "create directory failed"
cd "xml2/"
checkStatus $? "change directory failed"

# download source
curl -O ftp://xmlsoft.org/libxml2/libxml2-$5.tar.gz
checkStatus $? "download of libxml2 failed"

# unpack
tar -zxf "libxml2-$5.tar.gz"
checkStatus $? "unpack libxml2 failed"
cd "libxml2-$5/"
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
