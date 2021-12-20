#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory

# load functions
. $1/functions.sh

# load version
VERSION=$(cat "$1/../version/nasm")
checkStatus $? "load version failed"
echo "version: $VERSION"

# start in working directory
cd "$2"
checkStatus $? "change directory failed"
mkdir "nasm"
checkStatus $? "create directory failed"
cd "nasm/"
checkStatus $? "change directory failed"

# download source
curl -O -L http://www.nasm.us/pub/nasm/releasebuilds/$VERSION/nasm-$VERSION.tar.gz
checkStatus $? "download of nasm failed"

# unpack
tar -zxf "nasm-$VERSION.tar.gz"
checkStatus $? "unpack nasm failed"
cd "nasm-$VERSION/"
checkStatus $? "change directory failed"

# prepare build
./configure --prefix="$3"
checkStatus $? "configuration of nasm failed"

# build
make
checkStatus $? "build of nasm failed"

# install
make install
checkStatus $? "installation of nasm failed"
