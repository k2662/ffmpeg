#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs
# $5 = fontconfig version

# load functions
. $1/functions.sh

# start in working directory
cd "$2"
checkStatus $? "change directory failed"
mkdir "fontconfig"
checkStatus $? "create directory failed"
cd "fontconfig/"
checkStatus $? "change directory failed"

# download source
curl -O -L https://www.freedesktop.org/software/fontconfig/release/fontconfig-$5.tar.gz
checkStatus $? "download of fontconfig failed"

# unpack
tar -zxf "fontconfig-$5.tar.gz"
checkStatus $? "unpack fontconfig failed"
cd "fontconfig-$5/"
checkStatus $? "change directory failed"

# prepare build
# --with-default-fonts="" is used to fix current build on macOS
# https://gitlab.freedesktop.org/fontconfig/fontconfig/-/merge_requests/185
./configure --prefix="$3" --enable-static=yes --enable-shared=no --with-default-fonts=""
checkStatus $? "configuration of fontconfig failed"

# build
make -j $4
checkStatus $? "build of fontconfig failed"

# install
make install
checkStatus $? "installation of fontconfig failed"
