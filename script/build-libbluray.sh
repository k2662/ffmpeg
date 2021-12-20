#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs

# load functions
. $1/functions.sh

# load version
VERSION=$(cat "$1/../version/libbluray")
checkStatus $? "load version failed"
echo "version: $VERSION"

# start in working directory
cd "$2"
checkStatus $? "change directory failed"
mkdir "libbluray"
checkStatus $? "create directory failed"
cd "libbluray/"
checkStatus $? "change directory failed"

# download source
curl -O https://download.videolan.org/pub/videolan/libbluray/$VERSION/libbluray-$VERSION.tar.bz2
checkStatus $? "download of libbluray failed"

# unpack
bunzip2 "libbluray-$VERSION.tar.bz2"
checkStatus $? "unpack libbluray failed (bunzip2)"
tar -xf "libbluray-$VERSION.tar"
checkStatus $? "unpack libbluray failed (tar)"
cd "libbluray-$VERSION/"
checkStatus $? "change directory failed"

# prepare build
./configure --prefix="$3" --enable-shared=no --disable-bdjava-jar
checkStatus $? "configuration of libbluray failed"

# build
make -j $4
checkStatus $? "build of libbluray failed"

# install
make install
checkStatus $? "installation of libbluray failed"
