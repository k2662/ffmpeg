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
VERSION=$(cat "$1/../version/openh264")
checkStatus $? "load version failed"
echo "version: $VERSION"

# start in working directory
cd "$2"
checkStatus $? "change directory failed"
mkdir "openh264"
checkStatus $? "create directory failed"
cd "openh264/"
checkStatus $? "change directory failed"

# download source
curl -O -L https://github.com/cisco/openh264/archive/v$VERSION.tar.gz
checkStatus $? "download of openh264 failed"

# unpack
tar -zxf "v$VERSION.tar.gz"
checkStatus $? "unpack openh264 failed"
cd "openh264-$VERSION/"
checkStatus $? "change directory failed"

# build
make PREFIX="$3" -j $4
checkStatus $? "build of openh264 failed"

# install
make install-static PREFIX="$3"
checkStatus $? "installation of openh264 failed"
