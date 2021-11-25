#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs

# load functions
. $1/functions.sh

# load version
VERSION=$(cat "$1/../version/openssl")
checkStatus $? "load version failed"
echo "version: $VERSION"

# start in working directory
cd "$2"
checkStatus $? "change directory failed"
mkdir "openssl"
checkStatus $? "create directory failed"
cd "openssl/"
checkStatus $? "change directory failed"

# download source
curl -O https://www.openssl.org/source/openssl-$VERSION.tar.gz
checkStatus $? "download of openssl failed"

# TODO: checksum validation (if available)

# unpack
tar -zxf "openssl-$VERSION.tar.gz"
checkStatus $? "unpack of openssl failed"
cd "openssl-$VERSION/"
checkStatus $? "change directory failed"

# prepare build
./config --prefix="$3" --openssldir="$3/openssl" no-shared
checkStatus $? "configuration of openssl failed"

# build
make -j $4
checkStatus $? "build of openssl failed"

# install
## install without documentation
make install_sw
checkStatus $? "installation of openssl failed (install_sw)"
make install_ssldirs
checkStatus $? "installation of openssl failed (install_ssldirs)"
