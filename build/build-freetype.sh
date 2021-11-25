#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs

# load functions
. $1/functions.sh

# load version
VERSION=$(cat "$1/../version/freetype")
checkStatus $? "load version failed"
echo "version: $VERSION"

# start in working directory
cd "$2"
checkStatus $? "change directory failed"
mkdir "freetype"
checkStatus $? "create directory failed"
cd "freetype/"
checkStatus $? "change directory failed"

# download source
curl -O -L https://download.savannah.gnu.org/releases/freetype/freetype-$VERSION.tar.gz
checkStatus $? "download of freetype failed"

# unpack
tar -zxf "freetype-$VERSION.tar.gz"
checkStatus $? "unpack freetype failed"
cd "freetype-$VERSION/"
checkStatus $? "change directory failed"

# prepare build
./configure --prefix="$3" --enable-shared=no
checkStatus $? "configuration of freetype failed"

# build
make -j $4
checkStatus $? "build of freetype failed"

# install
make install
checkStatus $? "installation of freetype failed"
