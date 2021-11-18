#!/bin/sh

# parse arguments
SKIP_BUNDLE="NO"
SKIP_TEST="NO"
SKIP_AOM="NO"
SKIP_OPEN_H264="NO"
FFMPEG_SNAPSHOT="NO"
CPU_LIMIT=""
for arg in "$@"; do
    KEY=${arg%%=*}
    VALUE=${arg#*\=}
    if [ $KEY = "-SKIP_BUNDLE" ]; then
        SKIP_BUNDLE=$VALUE
        echo "skip bundle $VALUE"
    fi
    if [ $KEY = "-SKIP_TEST" ]; then
        SKIP_TEST=$VALUE
        echo "skip test $VALUE"
    fi
    if [ $KEY = "-SKIP_AOM" ]; then
        SKIP_AOM=$VALUE
        echo "skip aom $VALUE"
    fi
    if [ $KEY = "-SKIP_OPEN_H264" ]; then
        SKIP_OPEN_H264=$VALUE
        echo "skip openh264 $VALUE"
    fi
    if [ $KEY = "-FFMPEG_SNAPSHOT" ]; then
        FFMPEG_SNAPSHOT=$VALUE
        echo "use ffmpeg snapshot $VALUE"
    fi
    if [ $KEY = "-CPU_LIMIT" ]; then
        CPU_LIMIT=$VALUE
        echo "use cpu limit $VALUE"
    fi
done

# some folder names
BASE_DIR="$( cd "$( dirname "$0" )" > /dev/null 2>&1 && pwd )"
echo "base directory is ${BASE_DIR}"
SCRIPT_DIR="${BASE_DIR}/build"
echo "script directory is ${SCRIPT_DIR}"
WORKING_DIR="$( pwd )"
echo "working directory is ${WORKING_DIR}"
SOURCE_DIR="$WORKING_DIR/source"
echo "source code directory is ${SOURCE_DIR}"
LOG_DIR="$WORKING_DIR/log"
echo "logs code directory is ${LOG_DIR}"
TOOL_DIR="$WORKING_DIR/tool"
echo "tool directory is ${TOOL_DIR}"
OUT_DIR="$WORKING_DIR/out"
echo "output directory is ${OUT_DIR}"
if [ $SKIP_TEST = "NO" ]; then
    TEST_DIR="${BASE_DIR}/test"
    echo "test directory is ${TEST_DIR}"
    TEST_OUT_DIR="$WORKING_DIR/test"
    echo "test output directory is ${TEST_OUT_DIR}"
fi

# load functions
. $SCRIPT_DIR/functions.sh

# prepare workspace
echoSection "prepare workspace"
mkdir "$SOURCE_DIR"
checkStatus $? "unable to create source code directory"
mkdir "$LOG_DIR"
checkStatus $? "unable to create logs directory"
mkdir "$TOOL_DIR"
checkStatus $? "unable to create tool directory"
PATH="$TOOL_DIR/bin:$PATH"
mkdir "$OUT_DIR"
checkStatus $? "unable to create output directory"
if [ $SKIP_TEST = "NO" ]; then
    mkdir "$TEST_OUT_DIR"
    checkStatus $? "unable to create test output directory"
fi

# detect CPU threads (nproc for linux, sysctl for osx)
CPUS=1
if [ "$CPU_LIMIT" != "" ]; then
    CPUS=$CPU_LIMIT
else
    CPUS_NPROC="$(nproc 2> /dev/null)"
    if [ $? -eq 0 ]; then
        CPUS=$CPUS_NPROC
    else
        CPUS_SYSCTL="$(sysctl -n hw.ncpu 2> /dev/null)"
        if [ $? -eq 0 ]; then
            CPUS=$CPUS_SYSCTL
        fi
    fi
fi

echo "use ${CPUS} cpu threads"
echo "system info: $(uname -a)"
COMPILATION_START_TIME=$(currentTimeInSeconds)

# prepare build
FFMPEG_LIB_FLAGS="--enable-libx264 --enable-libx265 --enable-libvpx --enable-libmp3lame --enable-libopus"

# start build
START_TIME=$(currentTimeInSeconds)
echoSection "compile nasm"
$SCRIPT_DIR/build-nasm.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" "2.15.05" > "$LOG_DIR/build-nasm.log" 2>&1
checkStatus $? "build nasm"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile openssl"
$SCRIPT_DIR/build-openssl.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" "$CPUS" "1.1.1l" > "$LOG_DIR/build-openssl.log" 2>&1
checkStatus $? "build openssl"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile cmake"
$SCRIPT_DIR/build-cmake.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" "$CPUS" "3.21" "3.21.3" > "$LOG_DIR/build-cmake.log" 2>&1
checkStatus $? "build cmake"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile pkg-config"
$SCRIPT_DIR/build-pkg-config.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" "0.29.2" > "$LOG_DIR/build-pkg-config.log" 2>&1
checkStatus $? "build pkg-config"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile SDL"
$SCRIPT_DIR/build-sdl.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" "$CPUS" "2.0.14" > "$LOG_DIR/build-sdl.log" 2>&1
checkStatus $? "build SDL"
echoDurationInSections $START_TIME

if [ $SKIP_AOM = "NO" ]; then
    START_TIME=$(currentTimeInSeconds)
    echoSection "compile aom"
    $SCRIPT_DIR/build-aom.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" "$CPUS" "2.0.1" > "$LOG_DIR/build-aom.log" 2>&1
    checkStatus $? "build aom"
    echoDurationInSections $START_TIME
    FFMPEG_LIB_FLAGS="$FFMPEG_LIB_FLAGS --enable-libaom"
else
    echoSection "skip aom"
fi

if [ $SKIP_OPEN_H264 = "NO" ]; then
    START_TIME=$(currentTimeInSeconds)
    echoSection "compile openh264"
    $SCRIPT_DIR/build-openh264.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" "$CPUS" "2.1.1" > "$LOG_DIR/build-openh264.log" 2>&1
    checkStatus $? "build openh264"
    echoDurationInSections $START_TIME
    FFMPEG_LIB_FLAGS="$FFMPEG_LIB_FLAGS --enable-libopenh264"
else
    echoSection "skip openh264"
fi

START_TIME=$(currentTimeInSeconds)
echoSection "compile x264"
$SCRIPT_DIR/build-x264.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" "$CPUS" > "$LOG_DIR/build-x264.log" 2>&1
checkStatus $? "build x264"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile x265"
$SCRIPT_DIR/build-x265.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" "$CPUS" "3.4" > "$LOG_DIR/build-x265.log" 2>&1
checkStatus $? "build x265"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile vpx"
$SCRIPT_DIR/build-vpx.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" "$CPUS" "1.10.0" > "$LOG_DIR/build-vpx.log" 2>&1
checkStatus $? "build vpx"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile lame (mp3)"
$SCRIPT_DIR/build-lame.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" "3.100" > "$LOG_DIR/build-lame.log" 2>&1
checkStatus $? "build lame"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile opus"
$SCRIPT_DIR/build-opus.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" "$CPUS" "1.3.1" > "$LOG_DIR/build-opus.log" 2>&1
checkStatus $? "build opus"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile ffmpeg"
FFMPEG_VERSION="4.4.1"
if [ $FFMPEG_SNAPSHOT = "YES" ]; then
    FFMPEG_VERSION="snapshot"
fi
$SCRIPT_DIR/build-ffmpeg.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" "$OUT_DIR" "$CPUS" "$FFMPEG_VERSION" "$FFMPEG_LIB_FLAGS" > "$LOG_DIR/build-ffmpeg.log" 2>&1
checkStatus $? "build ffmpeg"
echoDurationInSections $START_TIME

echoSection "compilation finished successfully"
echoDurationInSections $COMPILATION_START_TIME

if [ $SKIP_BUNDLE = "NO" ]; then
    echoSection "bundle result"
    cd "$OUT_DIR/bin/"
    checkStatus $? "change directory"
    zip -9 -r "$WORKING_DIR/ffmpeg-success.zip" *
fi

if [ $SKIP_TEST = "NO" ]; then
    START_TIME=$(currentTimeInSeconds)
    echoSection "run tests"
    $TEST_DIR/test.sh "$SCRIPT_DIR" "$TEST_DIR" "$TEST_OUT_DIR" "$OUT_DIR" $SKIP_AOM $SKIP_OPEN_H264 > "$LOG_DIR/test.log" 2>&1
    checkStatus $? "test"
    echo "tests executed successfully"
    echoDurationInSections $START_TIME
fi
