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
# $4 = CPUs

# load functions
. $1/functions.sh

# load version
VERSION=$(cat "$1/../version/opus")
checkStatus $? "load version failed"
echo "version: $VERSION"

# start in working directory
cd "$2"
checkStatus $? "change directory failed"
mkdir "opus"
checkStatus $? "create directory failed"
cd "opus/"
checkStatus $? "change directory failed"

# download source
curl -O -L https://archive.mozilla.org/pub/opus/opus-$VERSION.tar.gz
checkStatus $? "download of opus failed"

# unpack
tar -zxf "opus-$VERSION.tar.gz"
checkStatus $? "unpack opus failed"
cd "opus-$VERSION/"
checkStatus $? "change directory failed"

# prepare build
./configure --prefix="$3" --enable-shared=no
checkStatus $? "configuration of opus failed"

# build
make -j $4
checkStatus $? "build of opus failed"

# install
make install
checkStatus $? "installation of opus failed"
