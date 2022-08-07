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

# handle arguments
echo "arguments: $@"
SCRIPT_DIR=$1
SOURCE_DIR=$2
TOOL_DIR=$3
CPUS=$4

# load functions
. $SCRIPT_DIR/functions.sh

# versions
VERSION_MAJOR="3.24"
VERSION_MINOR="3.24.0"

# detect existing installation of cmake
CURRENT_VERSION=$(cmake --version | grep -m 1 "" |  sed -r 's/.*([0-9]+\.[0-9]+\.[0-9]+)/\1/')
echo "detected installed version of cmake: $CURRENT_VERSION"
if [ "$CURRENT_VERSION" = "$VERSION_MINOR" ]; then
    echo "cmake already in current version available"
    exit 0
fi

# start in working directory
cd "$SOURCE_DIR"
checkStatus $? "change directory failed"
mkdir "cmake"
checkStatus $? "create directory failed"
cd "cmake/"
checkStatus $? "change directory failed"

# download source
download https://cmake.org/files/v$VERSION_MAJOR/cmake-$VERSION_MINOR.tar.gz "cmake.tar.gz"
checkStatus $? "download failed"

# unpack
tar -zxf "cmake.tar.gz"
checkStatus $? "unpack failed"
cd "cmake-$VERSION_MINOR/"
checkStatus $? "change directory failed"

# prepare build
export OPENSSL_ROOT_DIR="$TOOL_DIR"
./configure --prefix="$TOOL_DIR" --parallel="$CPUS"
checkStatus $? "configuration failed"

# build
make -j $CPUS
checkStatus $? "build failed"

# install
make install
checkStatus $? "installation failed"
