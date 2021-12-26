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
VERSION=$(cat "$1/../version/openssl")
checkStatus $? "load version failed"
echo "version: $VERSION"

# start in working directory
cd "$2"
checkStatus $? "change directory failed"
mkdir "openssl"
checkStatus $? "create directory failed"
cd "openssl/"
checkStatus $? "change directory failed"

# download source
curl -O https://www.openssl.org/source/openssl-$VERSION.tar.gz
checkStatus $? "download of openssl failed"

# unpack
tar -zxf "openssl-$VERSION.tar.gz"
checkStatus $? "unpack of openssl failed"
cd "openssl-$VERSION/"
checkStatus $? "change directory failed"

# prepare build
# use custom lib path, because for any reason on linux amd64 installs otherwise in lib64 instead
./config --prefix="$3" --openssldir="$3/openssl" --libdir="$3/lib" no-shared
checkStatus $? "configuration of openssl failed"

# build
make -j $4
checkStatus $? "build of openssl failed"

# install
## install without documentation
make install_sw
checkStatus $? "installation of openssl failed (install_sw)"
make install_ssldirs
checkStatus $? "installation of openssl failed (install_ssldirs)"
