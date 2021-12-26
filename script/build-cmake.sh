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

# versions
VERSION_MAJOR="3.22"
VERSION_MINOR="3.22.1"

# start in working directory
cd "$2"
checkStatus $? "change directory failed"
mkdir "cmake"
checkStatus $? "create directory failed"
cd "cmake/"
checkStatus $? "change directory failed"

# download source
curl -O https://cmake.org/files/v$VERSION_MAJOR/cmake-$VERSION_MINOR.tar.gz
checkStatus $? "download of cmake failed"

# unpack
tar -zxf "cmake-$VERSION_MINOR.tar.gz"
checkStatus $? "unpack of cmake failed"
cd "cmake-$VERSION_MINOR/"
checkStatus $? "change directory failed"

# prepare build
export OPENSSL_ROOT_DIR="$3"
./configure --prefix="$3" --parallel="$4"
checkStatus $? "configuration of cmake failed"

# build
make -j $4
checkStatus $? "build of cmake failed"

# install
make install
checkStatus $? "installation of cmake failed"
