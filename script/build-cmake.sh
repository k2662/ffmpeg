#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs

# load functions
. $1/functions.sh

# versions
VERSION_MAJOR="3.22"
VERSION_MINOR="3.22.1"

# start in working directory
cd "$2"
checkStatus $? "change directory failed"
mkdir "cmake"
checkStatus $? "create directory failed"
cd "cmake/"
checkStatus $? "change directory failed"

# download source
curl -O https://cmake.org/files/v$VERSION_MAJOR/cmake-$VERSION_MINOR.tar.gz
checkStatus $? "download of cmake failed"

# unpack
tar -zxf "cmake-$VERSION_MINOR.tar.gz"
checkStatus $? "unpack of cmake failed"
cd "cmake-$VERSION_MINOR/"
checkStatus $? "change directory failed"

# prepare build
export OPENSSL_ROOT_DIR="$3"
./configure --prefix="$3" --parallel="$4"
checkStatus $? "configuration of cmake failed"

# build
make -j $4
checkStatus $? "build of cmake failed"

# install
make install
checkStatus $? "installation of cmake failed"
