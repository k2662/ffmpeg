#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs

# load functions
. $1/functions.sh

# load version
VERSION=$(cat "$1/../version/zlib")
checkStatus $? "load version failed"
echo "version: $VERSION"

# start in working directory
cd "$2"
checkStatus $? "change directory failed"
mkdir "zlib"
checkStatus $? "create directory failed"
cd "zlib/"
checkStatus $? "change directory failed"

# download source
curl -O https://www.zlib.net/zlib-$VERSION.tar.gz
checkStatus $? "download of zlib failed"

# unpacking
tar -zxf "zlib-$VERSION.tar.gz"
checkStatus $? "unpacking failed"
cd "zlib-$VERSION/"
checkStatus $? "change directory failed"

# prepare build
./configure --prefix="$3" --static
checkStatus $? "configuration failed"

# build
make -j $4
checkStatus $? "build failed"

# install
make install
checkStatus $? "installation failed"
