#!/bin/sh

# Copyright 2024 Martin Riedl
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

# load version
VERSION=$(cat "$SCRIPT_DIR/../version/xevd")
checkStatus $? "load version failed"
echo "version: $VERSION"

# start in working directory
cd "$SOURCE_DIR"
checkStatus $? "change directory failed"
mkdir "xevd"
checkStatus $? "create directory failed"
cd "xevd/"
checkStatus $? "change directory failed"

# download source
download https://github.com/mpeg5/xevd/archive/refs/tags/v$VERSION.tar.gz "xevd.tar.gz"
checkStatus $? "download failed"

# unpack
tar -zxf "xevd.tar.gz"
checkStatus $? "unpack failed"

# create version file
echo "v$VERSION" > xevd-$VERSION/version.txt
checkStatus $? "create version file failed"

# prepare build
mkdir "build"
checkStatus $? "create directory failed"
cd "build/"
checkStatus $? "change directory failed"
cmake -DCMAKE_INSTALL_PREFIX:PATH=$TOOL_DIR ../xevd-$VERSION
checkStatus $? "configuration failed"

# build
make -j $CPUS
checkStatus $? "build failed"

# install
make install
checkStatus $? "installation failed"
