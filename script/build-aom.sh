#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs

# load functions
. $1/functions.sh

# load version
VERSION=$(cat "$1/../version/aom")
checkStatus $? "load version failed"
echo "version: $VERSION"

# start in working directory
cd "$2"
checkStatus $? "change directory failed"
mkdir "aom"
checkStatus $? "create directory failed"
cd "aom/"
checkStatus $? "change directory failed"

# download source
curl -O https://storage.googleapis.com/aom-releases/libaom-$VERSION.tar.gz
checkStatus $? "download of aom failed"

# unpack
tar -zxf "libaom-$VERSION.tar.gz"
checkStatus $? "unpack aom failed"

# prepare build
mkdir ../aom_build
checkStatus $? "create aom build directory failed"
cd ../aom_build
checkStatus $? "change directory to aom build failed"
cmake -DCMAKE_INSTALL_PREFIX:PATH=$3 -DENABLE_TESTS=0 ../aom/
checkStatus $? "configuration of aom failed"

# build
make -j $4
checkStatus $? "build of aom failed"

# install
make install
checkStatus $? "installation of aom failed"
