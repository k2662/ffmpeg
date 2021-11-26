#!/bin/sh
# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = CPUs
# $5 = skip multi-bit

# load functions
. $1/functions.sh

# load version
VERSION=$(cat "$1/../version/x265")
checkStatus $? "load version failed"
echo "version: $VERSION"

# start in working directory
cd "$2"
checkStatus $? "change directory failed"
mkdir "x265"
checkStatus $? "create directory failed"
cd "x265/"
checkStatus $? "change directory failed"

# download source
curl -O -L https://github.com/videolan/x265/archive/$VERSION.tar.gz
checkStatus $? "download of x265 failed"

# unpack
tar -zxf "$VERSION.tar.gz"
checkStatus $? "unpack x265 failed"
cd "x265-$VERSION/"
checkStatus $? "change directory failed"

if [ $5 = "NO" ]; then
    # prepare build 10 bit
    echo "start with 10bit build"
    mkdir 10bit
    checkStatus $? "create directory failed"
    cd 10bit/
    checkStatus $? "change directory failed"
    cmake -DCMAKE_INSTALL_PREFIX:PATH=$3 -DENABLE_SHARED=NO -DENABLE_CLI=OFF -DEXPORT_C_API=OFF -DHIGH_BIT_DEPTH=ON ../source
    checkStatus $? "configuration of x265 10 bit failed"

    # build 10 bit
    make -j $4
    checkStatus $? "build of x265 10 bit failed"
    cd ..
    checkStatus $? "change directory failed"

    # prepare build 12 bit
    echo "start with 12bit build"
    mkdir 12bit
    checkStatus $? "create directory failed"
    cd 12bit/
    checkStatus $? "change directory failed"
    cmake -DCMAKE_INSTALL_PREFIX:PATH=$3 -DENABLE_SHARED=NO -DENABLE_CLI=OFF -DEXPORT_C_API=OFF -DHIGH_BIT_DEPTH=ON -DMAIN12=ON ../source
    checkStatus $? "configuration of x265 12 bit failed"

    # build 12 bit
    make -j $4
    checkStatus $? "build of x265 12 bit failed"
    cd ..
    checkStatus $? "change directory failed"

    # prepare build 8 bit
    echo "start with 8bit build"
    ln -s 10bit/libx265.a libx265_10bit.a
    checkStatus $? "symlink creation of 10 bit library failed"
    ln -s 12bit/libx265.a libx265_12bit.a
    checkStatus $? "symlink creation of 12 bit library failed"
    cmake -DCMAKE_INSTALL_PREFIX:PATH=$3 -DENABLE_SHARED=NO \
        -DEXTRA_LINK_FLAGS=-L. -DEXTRA_LIB="x265_10bit.a;x265_12bit.a" -DLINKED_10BIT=ON -DLINKED_12BIT=ON source
    checkStatus $? "configuration of x265 8 bit failed"

    # build 8 bit
    make -j $4
    checkStatus $? "build of x265 8 bit failed"

    # merge libraries
    mv libx265.a libx265_8bit.a
    checkStatus $? "move 8 bit library failed"
    if [ "$(uname)" = "Linux" ]; then
    ar -M <<EOF
CREATE libx265.a
ADDLIB libx265_8bit.a
ADDLIB libx265_10bit.a
ADDLIB libx265_12bit.a
SAVE
END
EOF
    else
        libtool -static -o libx265.a libx265_8bit.a libx265_10bit.a libx265_12bit.a
    fi
    checkStatus $? "multi-bit library creation failed"
else
    # prepare build
    cmake -DCMAKE_INSTALL_PREFIX:PATH=$3 -DENABLE_SHARED=NO source
    checkStatus $? "configuration of x265 failed"

    # build
    make -j $4
    checkStatus $? "build of x265 failed"
fi

# install
make install
checkStatus $? "installation of x265 failed"

# post-installation
# modify pkg-config file for usage with ffmpeg (it seems that the flag for threads is missing)
sed -i.original -e 's/lx265/lx265 -lpthread/g' $3/lib/pkgconfig/x265.pc
