#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs

# load functions
. $1/functions.sh

# load version
VERSION=$(cat "$1/../version/sdl")
checkStatus $? "load version failed"
echo "version: $VERSION"

# start in working directory
cd "$2"
checkStatus $? "change directory failed"
mkdir "sdl"
checkStatus $? "create directory failed"
cd "sdl/"
checkStatus $? "change directory failed"

# download source
curl -O -L https://www.libsdl.org/release/SDL2-$VERSION.tar.gz
checkStatus $? "download of SDL failed"

# unpack
tar -zxf "SDL2-$VERSION.tar.gz"
checkStatus $? "unpack SDL failed"
cd "SDL2-$VERSION/"
checkStatus $? "change directory failed"

# prepare build
./configure --prefix="$3" --enable-shared=no
checkStatus $? "configuration of SDL failed"

# build
make -j $4
checkStatus $? "build of SDL failed"

# install
make install
checkStatus $? "installation of SDL failed"
