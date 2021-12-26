#!/bin/sh

# Copyright 2021 Martin Riedl
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# $1 = script directory
# $2 = working directory
# $3 = tool directory
# $4 = output directory
# $5 = CPUs
# $6 = FFmpeg snapshot flag
# $7 = FFmpeg library flags

# load functions
. $1/functions.sh

# version
if [ $6 = "YES" ]; then
    VERSION="snapshot"
else
    # load version
    VERSION=$(cat "$1/../version/ffmpeg")
    checkStatus $? "load version failed"
fi
echo "version: $VERSION"

# start in working directory
cd $2
checkStatus $? "change directory failed"
mkdir "ffmpeg"
checkStatus $? "create directory failed"
cd "ffmpeg/"
checkStatus $? "change directory failed"

# download ffmpeg source
curl -o ffmpeg.tar.bz2 https://ffmpeg.org/releases/ffmpeg-$VERSION.tar.bz2
checkStatus $? "ffmpeg download failed"

# unpack ffmpeg
mkdir "ffmpeg"
checkStatus $? "create directory failed"
bunzip2 ffmpeg.tar.bz2
checkStatus $? "unpack ffmpeg failed (bunzip2)"
tar -xf ffmpeg.tar -C ffmpeg --strip-components=1
checkStatus $? "unpack ffmpeg failed (tar)"
cd "ffmpeg/"
checkStatus $? "change directory failed"

# prepare build
EXTRA_VERSION="https://www.martin-riedl.de"
FF_FLAGS="-L${3}/lib -I${3}/include"
export LDFLAGS="$FF_FLAGS"
export CFLAGS="$FF_FLAGS"
# --pkg-config-flags="--static" is required to respect the Libs.private flags of the *.pc files
./configure --prefix="$4" --enable-gpl --pkg-config-flags="--static" --extra-version="$EXTRA_VERSION" \
    --enable-gray $7
checkStatus $? "configuration of ffmpeg failed"

# start build
make -j $5
checkStatus $? "build of ffmpeg failed"

# install ffmpeg
make install
checkStatus $? "installation of ffmpeg failed"
