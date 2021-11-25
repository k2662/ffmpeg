#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory

# load functions
. $1/functions.sh

# load version
VERSION=$(cat "$1/../version/lame")
checkStatus $? "load version failed"
echo "version: $VERSION"

# start in working directory
cd "$2"
checkStatus $? "change directory failed"
mkdir "lame"
checkStatus $? "create directory failed"
cd "lame/"
checkStatus $? "change directory failed"

# download source
curl -O https://netcologne.dl.sourceforge.net/project/lame/lame/$VERSION/lame-$VERSION.tar.gz
checkStatus $? "download of lame failed"

# unpack
tar -zxf "lame-$VERSION.tar.gz"
checkStatus $? "unpack lame failed"
cd "lame-$VERSION/"
checkStatus $? "change directory failed"

# prepare build
./configure --prefix="$3" --enable-shared=no
checkStatus $? "configuration of lame failed"

# build
make
checkStatus $? "build of lame failed"

# install
make install
checkStatus $? "installation of lame failed"
