#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs

# load functions
. $1/functions.sh

# load version
VERSION=$(cat "$1/../version/zvbi")
checkStatus $? "load version failed"
echo "version: $VERSION"

# start in working directory
cd "$2"
checkStatus $? "change directory failed"
mkdir "zvbi"
checkStatus $? "create directory failed"
cd "zvbi/"
checkStatus $? "change directory failed"

# download source
curl -o zvbi.tar.bz2 -L https://sourceforge.net/projects/zapping/files/zvbi/$VERSION/zvbi-$VERSION.tar.bz2/download
checkStatus $? "download failed"

# unpack
bunzip2 "zvbi.tar.bz2"
checkStatus $? "unpack (bunzip2)"
tar -xf "zvbi.tar"
checkStatus $? "unpack (tar)"
cd "zvbi-$VERSION/"
checkStatus $? "change directory failed"

# prepare build
./configure --prefix="$3" --enable-shared=no
checkStatus $? "configuration failed"

# build
make -j $4
checkStatus $? "build failed"

# install
make install
checkStatus $? "installation failed"
