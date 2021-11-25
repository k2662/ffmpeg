#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs

# load functions
. $1/functions.sh

# load version
VERSION=$(cat "$1/../version/fontconfig")
checkStatus $? "load version failed"
echo "version: $VERSION"

# start in working directory
cd "$2"
checkStatus $? "change directory failed"
mkdir "fontconfig"
checkStatus $? "create directory failed"
cd "fontconfig/"
checkStatus $? "change directory failed"

# download source
curl -O -L https://www.freedesktop.org/software/fontconfig/release/fontconfig-$VERSION.tar.gz
checkStatus $? "download of fontconfig failed"

# unpack
tar -zxf "fontconfig-$VERSION.tar.gz"
checkStatus $? "unpack fontconfig failed"
cd "fontconfig-$VERSION/"
checkStatus $? "change directory failed"

# prepare build
# --with-default-fonts="" is used to fix current build on macOS
# https://gitlab.freedesktop.org/fontconfig/fontconfig/-/merge_requests/185
./configure --prefix="$3" --enable-static=yes --enable-shared=no --enable-libxml2 --with-default-fonts=""
checkStatus $? "configuration of fontconfig failed"

# build
make -j $4
checkStatus $? "build of fontconfig failed"

# install
make install
checkStatus $? "installation of fontconfig failed"
