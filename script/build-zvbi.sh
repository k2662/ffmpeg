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
VERSION=$(cat "$1/../version/zvbi")
checkStatus $? "load version failed"
echo "version: $VERSION"

# start in working directory
cd "$2"
checkStatus $? "change directory failed"
mkdir "zvbi"
checkStatus $? "create directory failed"
cd "zvbi/"
checkStatus $? "change directory failed"

# download source
curl -o zvbi.tar.bz2 -L https://sourceforge.net/projects/zapping/files/zvbi/$VERSION/zvbi-$VERSION.tar.bz2/download
checkStatus $? "download failed"

# unpack
bunzip2 "zvbi.tar.bz2"
checkStatus $? "unpack (bunzip2)"
tar -xf "zvbi.tar"
checkStatus $? "unpack (tar)"
cd "zvbi-$VERSION/"
checkStatus $? "change directory failed"

# prepare build
./configure --prefix="$3" --enable-shared=no
checkStatus $? "configuration failed"

# build
make -j $4
checkStatus $? "build failed"

# install
make install
checkStatus $? "installation failed"
