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
TEST_DIR=$2
TEST_OUT_DIR=$3
OUT_DIR=$4
SKIP_AOM=$5
SKIP_OPEN_H264=$6
SKIP_X264=$7
SKIP_X265=$8

# load functions
. $SCRIPT_DIR/functions.sh

# test freetype
START_TIME=$(currentTimeInSeconds)
echoSection "run test freetype encoding"
$OUT_DIR/bin/ffmpeg -i "$TEST_DIR/test.mp4" -frames:v 1 -vf "drawtext=fontfile=$TEST_DIR/NotoSans-Regular.ttf:text='Martin Riedl':fontcolor=white:fontsize=24:box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=(h-text_h)/2" "$TEST_OUT_DIR/test-freetype.jpeg" > "$TEST_OUT_DIR/test-freetype.log" 2>&1
checkStatus $? "test freetype"
echoDurationInSections $START_TIME

# TODO: test fontconfig
#START_TIME=$(currentTimeInSeconds)
#echoSection "run test fontconfig encoding"
#$OUT_DIR/bin/ffmpeg -i "$TEST_DIR/test.mp4" -frames:v 1 -vf "drawtext=font='Sans':text='Martin Riedl':fontcolor=white:fontsize=24:box=1:boxcolor=black@0.5:boxborderw=5:x=(w-text_w)/2:y=(h-text_h)/2" "$TEST_OUT_DIR/test-fontconfig.png" > "$TEST_OUT_DIR/test-fontconfig.log" 2>&1
#checkStatus $? "test fontconfig"
#echoDurationInSections $START_TIME

# TODO: test for libbluray

# test aom av1
if [ $SKIP_AOM = "NO" ]; then
    START_TIME=$(currentTimeInSeconds)
    echoSection "run test aom av1 encoding"
    $OUT_DIR/bin/ffmpeg -i "$TEST_DIR/test.mp4" -c:v "libaom-av1" -cpu-used 8 -an "$TEST_OUT_DIR/test-aom-av1.mp4" > "$TEST_OUT_DIR/test-aom-av1.log" 2>&1
    checkStatus $? "test aom av1"
    echoDurationInSections $START_TIME
fi

# test openh264
if [ $SKIP_OPEN_H264 = "NO" ]; then
    START_TIME=$(currentTimeInSeconds)
    echoSection "run test openh264 encoding"
    $OUT_DIR/bin/ffmpeg -i "$TEST_DIR/test.mp4" -c:v "libopenh264" -an "$TEST_OUT_DIR/test-openh264.mp4" > "$TEST_OUT_DIR/test-openh264.log" 2>&1
    checkStatus $? "test openh264"
    echoDurationInSections $START_TIME
fi

# test x264
if [ $SKIP_X264 = "NO" ]; then
    START_TIME=$(currentTimeInSeconds)
    echoSection "run test x264 encoding"
    $OUT_DIR/bin/ffmpeg -i "$TEST_DIR/test.mp4" -c:v "libx264" -an "$TEST_OUT_DIR/test-x264.mp4" > "$TEST_OUT_DIR/test-x264.log" 2>&1
    checkStatus $? "test x264"
    echoDurationInSections $START_TIME
fi

# test x265
if [ $SKIP_X265 = "NO" ]; then
    START_TIME=$(currentTimeInSeconds)
    echoSection "run test x265 encoding"
    $OUT_DIR/bin/ffmpeg -i "$TEST_DIR/test.mp4" -c:v "libx265" -an "$TEST_OUT_DIR/test-x265.mp4" > "$TEST_OUT_DIR/test-x265.log" 2>&1
    checkStatus $? "test x265"
    echoDurationInSections $START_TIME
fi

# test vp8
START_TIME=$(currentTimeInSeconds)
echoSection "run test vp8 encoding"
$OUT_DIR/bin/ffmpeg -i "$TEST_DIR/test.mp4" -c:v "libvpx" -an "$TEST_OUT_DIR/test-vp8.webm" > "$TEST_OUT_DIR/test-vp8.log" 2>&1
checkStatus $? "test vp8"
echoDurationInSections $START_TIME

# test vp9
START_TIME=$(currentTimeInSeconds)
echoSection "run test vp9 encoding"
$OUT_DIR/bin/ffmpeg -i "$TEST_DIR/test.mp4" -c:v "libvpx-vp9" -an "$TEST_OUT_DIR/test-vp9.webm" > "$TEST_OUT_DIR/test-vp9.log" 2>&1
checkStatus $? "test vp9"
echoDurationInSections $START_TIME

# test lame mp3
START_TIME=$(currentTimeInSeconds)
echoSection "run test lame mp3 encoding"
$OUT_DIR/bin/ffmpeg -i "$TEST_DIR/test.mp4" -c:a "libmp3lame" -vn "$TEST_OUT_DIR/test-lame.mp3" > "$TEST_OUT_DIR/test-lame.log" 2>&1
checkStatus $? "test lame mp3"
echoDurationInSections $START_TIME

# test opus
START_TIME=$(currentTimeInSeconds)
echoSection "run test opus encoding"
$OUT_DIR/bin/ffmpeg -i "$TEST_DIR/test.mp4" -c:a "libopus" -vn "$TEST_OUT_DIR/test-opus.opus" > "$TEST_OUT_DIR/test-opus.log" 2>&1
checkStatus $? "test opus"
echoDurationInSections $START_TIME
