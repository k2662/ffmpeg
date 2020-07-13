#!/bin/sh
# $1 = build directory
# $2 = test directory
# $3 = working directory
# $4 = output directory

# load functions
. $1/functions.sh

# test lame mp3
$4/bin/ffmpeg -i "$2/test.mp4" -c:a "libmp3lame" -vn "$3/test-lame.mp3" > "$3/test-lame.log" 2>&1
checkStatus $? "test lame mp3 failed"

# test aom av1
$4/bin/ffmpeg -i "$2/test.mp4" -c:v "libaom-av1" -an "$3/test-aom-av1.mp4" > "$3/test-aom-av1.log" 2>&1
checkStatus $? "test aom av1 failed"

# test x264
$4/bin/ffmpeg -i "$2/test.mp4" -c:v "libx264" -an "$3/test-x264.mp4" > "$3/test-x264.log" 2>&1
checkStatus $? "test x264 failed"

# test x265
$4/bin/ffmpeg -i "$2/test.mp4" -c:v "libx265" -an "$3/test-x265.mp4" > "$3/test-x265.log" 2>&1
checkStatus $? "test x265 failed"

# test vp8
$4/bin/ffmpeg -i "$2/test.mp4" -c:v "libvpx" -an "$3/test-vp8.webm" > "$3/test-vp8.log" 2>&1
checkStatus $? "test vp8 failed"

# test vp9
$4/bin/ffmpeg -i "$2/test.mp4" -c:v "libvpx-vp9" -an "$3/test-vp9.webm" > "$3/test-vp9.log" 2>&1
checkStatus $? "test vp9 failed"
