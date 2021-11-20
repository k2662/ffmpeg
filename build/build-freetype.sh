#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs
# $5 = freetype version

# load functions
. $1/functions.sh

# start in working directory
cd "$2"
checkStatus $? "change directory failed"
mkdir "freetype"
checkStatus $? "create directory failed"
cd "freetype/"
checkStatus $? "change directory failed"

# download source
curl -O -L https://download.savannah.gnu.org/releases/freetype/freetype-$5.tar.gz
checkStatus $? "download of freetype failed"

# unpack
tar -zxf "freetype-$5.tar.gz"
checkStatus $? "unpack freetype failed"
cd "freetype-$5/"
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
