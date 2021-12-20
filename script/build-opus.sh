#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs

# load functions
. $1/functions.sh

# load version
VERSION=$(cat "$1/../version/opus")
checkStatus $? "load version failed"
echo "version: $VERSION"

# start in working directory
cd "$2"
checkStatus $? "change directory failed"
mkdir "opus"
checkStatus $? "create directory failed"
cd "opus/"
checkStatus $? "change directory failed"

# download source
curl -O -L https://archive.mozilla.org/pub/opus/opus-$VERSION.tar.gz
checkStatus $? "download of opus failed"

# unpack
tar -zxf "opus-$VERSION.tar.gz"
checkStatus $? "unpack opus failed"
cd "opus-$VERSION/"
checkStatus $? "change directory failed"

# prepare build
./configure --prefix="$3" --enable-shared=no
checkStatus $? "configuration of opus failed"

# build
make -j $4
checkStatus $? "build of opus failed"

# install
make install
checkStatus $? "installation of opus failed"
