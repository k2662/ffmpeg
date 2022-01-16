#!/bin/sh

# Copyright 2022 Martin Riedl
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
# $4 = CPUs

# load functions
. $1/functions.sh

# load version
VERSION=$(cat "$1/../version/svt-av1")
checkStatus $? "load version failed"
echo "version: $VERSION"

# start in working directory
cd "$2"
checkStatus $? "change directory failed"
mkdir "svt-av1"
checkStatus $? "create directory failed"
cd "svt-av1/"
checkStatus $? "change directory failed"

# download source
curl -O https://gitlab.com/AOMediaCodec/SVT-AV1/-/archive/v$VERSION/SVT-AV1-v$VERSION.tar.gz
checkStatus $? "download failed"

# unpack
tar -zxf "SVT-AV1-v$VERSION.tar.gz"
checkStatus $? "unpack failed"

# prepare build
mkdir "build"
checkStatus $? "create directory failed"
cd "build/"
checkStatus $? "change directory failed"
cmake -DCMAKE_INSTALL_PREFIX:PATH=$3 -DBUILD_SHARED_LIBS=NO -DBUILD_APPS=NO ../SVT-AV1-v$VERSION
checkStatus $? "configuration failed"

# build
make -j $4
checkStatus $? "build failed"

# install
make install
checkStatus $? "installation failed"
