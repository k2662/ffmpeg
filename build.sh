#!/bin/sh

# some folder names
SCRIPT_DIR="$( cd "$( dirname "$0" )" > /dev/null 2>&1 && pwd )/build"
echo "script directory is ${SCRIPT_DIR}"
WORKING_DIR="$( pwd )"
echo "working directory is ${WORKING_DIR}"
TOOL_DIR="$WORKING_DIR/tool"
echo "tool directory is ${TOOL_DIR}"
OUT_DIR="$WORKING_DIR/out"
echo "output directory is ${OUT_DIR}"

# load functions
. $SCRIPT_DIR/functions.sh

# prepare workspace
echoSection "prepare workspace"
mkdir "$TOOL_DIR"
checkStatus $? "unable to create tool directory"
PATH="$TOOL_DIR/bin:$PATH"
mkdir "$OUT_DIR"
checkStatus $? "unable to create output directory"

# detect CPU threads (nproc for linux, sysctl for osx)
CPUS=1
CPUS_NPROC="$(nproc 2> /dev/null)"
if [ $? -eq 0 ]
then
    CPUS=$CPUS_NPROC
else
    CPUS_SYSCTL="$(sysctl -n hw.ncpu 2> /dev/null)"
    if [ $? -eq 0 ]
    then
        CPUS=$CPUS_SYSCTL
    fi
fi

echo "use ${CPUS} cpu threads"

# start build
echoSection "compile nasm"
$SCRIPT_DIR/build-nasm.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "2.14.02" > "$WORKING_DIR/build-nasm.log" 2>&1
checkStatus $? "build nasm"

echoSection "compile cmake"
$SCRIPT_DIR/build-cmake.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "$CPUS" "3.16" "3.16.2" > "$WORKING_DIR/build-cmake.log" 2>&1
checkStatus $? "build cmake"

echoSection "compile pkg-config"
$SCRIPT_DIR/build-pkg-config.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "0.29.2" > "$WORKING_DIR/build-pkg-config.log" 2>&1
checkStatus $? "build pkg-config"

echoSection "compile x264"
$SCRIPT_DIR/build-x264.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "$CPUS" > "$WORKING_DIR/build-x264.log" 2>&1
checkStatus $? "build x264"

echoSection "compile x265"
$SCRIPT_DIR/build-x265.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "$CPUS" "3.2.1" > "$WORKING_DIR/build-x265.log" 2>&1
checkStatus $? "build x265"

echoSection "compile vpx"
$SCRIPT_DIR/build-vpx.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "$CPUS" "1.8.2" > "$WORKING_DIR/build-vpx.log" 2>&1
checkStatus $? "build vpx"

echoSection "compile lame (mp3)"
$SCRIPT_DIR/build-lame.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "3.100" > "$WORKING_DIR/build-lame.log" 2>&1
checkStatus $? "build lame"

echoSection "compile ffmpeg"
$SCRIPT_DIR/build-ffmpeg.sh "$SCRIPT_DIR" "$WORKING_DIR" "$TOOL_DIR" "$OUT_DIR" "$CPUS" "4.2.2" > "$WORKING_DIR/build-ffmpeg.log" 2>&1
checkStatus $? "build ffmpeg"

echoSection "bundle result"
cd "$OUT_DIR/bin/"
checkStatus $? "change directory failed"
zip -9 -r "$WORKING_DIR/ffmpeg-success.zip" *
