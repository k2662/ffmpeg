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

# load version
VERSION=$(cat "$SCRIPT_DIR/../version/fontconfig")
checkStatus $? "load version failed"
echo "version: $VERSION"

# start in working directory
cd "$SOURCE_DIR"
checkStatus $? "change directory failed"
mkdir "fontconfig"
checkStatus $? "create directory failed"
cd "fontconfig/"
checkStatus $? "change directory failed"

# download source
curl -O -L https://www.freedesktop.org/software/fontconfig/release/fontconfig-$VERSION.tar.gz
checkStatus $? "download failed"

# unpack
tar -zxf "fontconfig-$VERSION.tar.gz"
checkStatus $? "unpack failed"
cd "fontconfig-$VERSION/"
checkStatus $? "change directory failed"

# prepare build
# --with-default-fonts="" is used to fix current build on macOS
# https://gitlab.freedesktop.org/fontconfig/fontconfig/-/merge_requests/185
./configure --prefix="$TOOL_DIR" --enable-static=yes --enable-shared=no --enable-libxml2 --with-default-fonts=""
checkStatus $? "configuration failed"

# build
make -j $CPUS
checkStatus $? "build failed"

# install
make install
checkStatus $? "installation failed"
