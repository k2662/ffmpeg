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

# parse arguments
SKIP_BUNDLE="NO"
SKIP_TEST="NO"
SKIP_LIBBLURAY="NO"
SKIP_ZVBI="NO"
SKIP_AOM="NO"
SKIP_OPEN_H264="NO"
SKIP_RAV1E="NO"
SKIP_SVT_AV1="NO"
SKIP_LIBTHEORA="NO"
SKIP_VPX="NO"
SKIP_X264="NO"
SKIP_X265="NO"
SKIP_X265_MULTIBIT="NO"
SKIP_LAME="NO"
SKIP_OPUS="NO"
SKIP_LIBVORBIS="NO"
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
    if [ $KEY = "-SKIP_LIBBLURAY" ]; then
        SKIP_LIBBLURAY=$VALUE
        echo "skip libbluray $VALUE"
    fi
    if [ $KEY = "-SKIP_ZVBI" ]; then
        SKIP_ZVBI=$VALUE
        echo "skip zvbi $VALUE"
    fi
    if [ $KEY = "-SKIP_AOM" ]; then
        SKIP_AOM=$VALUE
        echo "skip aom $VALUE"
    fi
    if [ $KEY = "-SKIP_OPEN_H264" ]; then
        SKIP_OPEN_H264=$VALUE
        echo "skip openh264 $VALUE"
    fi
    if [ $KEY = "-SKIP_RAV1E" ]; then
        SKIP_RAV1E=$VALUE
        echo "skip rav1e $VALUE"
    fi
    if [ $KEY = "-SKIP_SVT_AV1" ]; then
        SKIP_SVT_AV1=$VALUE
        echo "skip svt-av1 $VALUE"
    fi
    if [ $KEY = "-SKIP_LIBTHEORA" ]; then
        SKIP_LIBTHEORA=$VALUE
        echo "skip libtheora $VALUE"
    fi
    if [ $KEY = "-SKIP_VPX" ]; then
        SKIP_VPX=$VALUE
        echo "skip vpx $VALUE"
    fi
    if [ $KEY = "-SKIP_X264" ]; then
        SKIP_X264=$VALUE
        echo "skip x264 $VALUE"
    fi
    if [ $KEY = "-SKIP_X265" ]; then
        SKIP_X265=$VALUE
        echo "skip x265 $VALUE"
    fi
    if [ $KEY = "-SKIP_X265_MULTIBIT" ]; then
        SKIP_X265_MULTIBIT=$VALUE
        echo "skip x265 multibit $VALUE"
    fi
    if [ $KEY = "-SKIP_LAME" ]; then
        SKIP_LAME=$VALUE
        echo "skip lame (mp3) $VALUE"
    fi
    if [ $KEY = "-SKIP_OPUS" ]; then
        SKIP_OPUS=$VALUE
        echo "skip opus $VALUE"
    fi
    if [ $KEY = "-SKIP_LIBVORBIS" ]; then
        SKIP_LIBVORBIS=$VALUE
        echo "skip libvorbis $VALUE"
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
SCRIPT_DIR="${BASE_DIR}/script"
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
FFMPEG_LIB_FLAGS=""

# start build
START_TIME=$(currentTimeInSeconds)
echoSection "compile nasm"
$SCRIPT_DIR/build-nasm.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" "$CPUS" > "$LOG_DIR/build-nasm.log" 2>&1
checkStatus $? "build nasm"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile pkg-config"
$SCRIPT_DIR/build-pkg-config.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" > "$LOG_DIR/build-pkg-config.log" 2>&1
checkStatus $? "build pkg-config"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile zlib"
$SCRIPT_DIR/build-zlib.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" "$CPUS" > "$LOG_DIR/build-zlib.log" 2>&1
checkStatus $? "build zlib"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile openssl"
$SCRIPT_DIR/build-openssl.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" "$CPUS" > "$LOG_DIR/build-openssl.log" 2>&1
checkStatus $? "build openssl"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile cmake"
$SCRIPT_DIR/build-cmake.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" "$CPUS" > "$LOG_DIR/build-cmake.log" 2>&1
checkStatus $? "build cmake"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile libxml2"
$SCRIPT_DIR/build-libxml2.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" "$CPUS" > "$LOG_DIR/build-libxml2.log" 2>&1
checkStatus $? "build libxml2"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile fribidi"
$SCRIPT_DIR/build-fribidi.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" "$CPUS" > "$LOG_DIR/build-fribidi.log" 2>&1
checkStatus $? "build fribidi"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile freetype"
$SCRIPT_DIR/build-freetype.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" "$CPUS" > "$LOG_DIR/build-freetype.log" 2>&1
checkStatus $? "build freetype"
echoDurationInSections $START_TIME
FFMPEG_LIB_FLAGS="$FFMPEG_LIB_FLAGS --enable-libfreetype"

START_TIME=$(currentTimeInSeconds)
echoSection "compile fontconfig"
$SCRIPT_DIR/build-fontconfig.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" "$CPUS" > "$LOG_DIR/build-fontconfig.log" 2>&1
checkStatus $? "build fontconfig"
echoDurationInSections $START_TIME
FFMPEG_LIB_FLAGS="$FFMPEG_LIB_FLAGS --enable-fontconfig"

START_TIME=$(currentTimeInSeconds)
echoSection "compile harfbuzz"
$SCRIPT_DIR/build-harfbuzz.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" "$CPUS" > "$LOG_DIR/build-harfbuzz.log" 2>&1
checkStatus $? "build harfbuzz"
echoDurationInSections $START_TIME

START_TIME=$(currentTimeInSeconds)
echoSection "compile SDL"
$SCRIPT_DIR/build-sdl.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" "$CPUS" > "$LOG_DIR/build-sdl.log" 2>&1
checkStatus $? "build SDL"
echoDurationInSections $START_TIME

if [ $SKIP_LIBBLURAY = "NO" ]; then
    START_TIME=$(currentTimeInSeconds)
    echoSection "compile libbluray"
    $SCRIPT_DIR/build-libbluray.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" "$CPUS" > "$LOG_DIR/build-libbluray.log" 2>&1
    checkStatus $? "build libbluray"
    echoDurationInSections $START_TIME
    FFMPEG_LIB_FLAGS="$FFMPEG_LIB_FLAGS --enable-libbluray"
    echo "NO" > "$LOG_DIR/skip-libbluray"
else
    echoSection "skip libbluray"
    echo "YES" > "$LOG_DIR/skip-libbluray"
fi

START_TIME=$(currentTimeInSeconds)
echoSection "compile libass"
$SCRIPT_DIR/build-libass.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" "$CPUS" > "$LOG_DIR/build-libass.log" 2>&1
checkStatus $? "build libass"
echoDurationInSections $START_TIME
FFMPEG_LIB_FLAGS="$FFMPEG_LIB_FLAGS --enable-libass"

START_TIME=$(currentTimeInSeconds)
echoSection "compile libogg"
$SCRIPT_DIR/build-libogg.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" "$CPUS" > "$LOG_DIR/build-libogg.log" 2>&1
checkStatus $? "build libogg"
echoDurationInSections $START_TIME

if [ $SKIP_ZVBI = "NO" ]; then
    START_TIME=$(currentTimeInSeconds)
    echoSection "compile zvbi"
    $SCRIPT_DIR/build-zvbi.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" "$CPUS" > "$LOG_DIR/build-zvbi.log" 2>&1
    checkStatus $? "build zvbi"
    echoDurationInSections $START_TIME
    FFMPEG_LIB_FLAGS="$FFMPEG_LIB_FLAGS --enable-libzvbi"
    echo "NO" > "$LOG_DIR/skip-zvbi"
else
    echoSection "skip zvbi"
    echo "YES" > "$LOG_DIR/skip-zvbi"
fi

if [ $SKIP_AOM = "NO" ]; then
    START_TIME=$(currentTimeInSeconds)
    echoSection "compile aom"
    $SCRIPT_DIR/build-aom.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" "$CPUS" > "$LOG_DIR/build-aom.log" 2>&1
    checkStatus $? "build aom"
    echoDurationInSections $START_TIME
    FFMPEG_LIB_FLAGS="$FFMPEG_LIB_FLAGS --enable-libaom"
    echo "NO" > "$LOG_DIR/skip-aom"
else
    echoSection "skip aom"
    echo "YES" > "$LOG_DIR/skip-aom"
fi

if [ $SKIP_OPEN_H264 = "NO" ]; then
    START_TIME=$(currentTimeInSeconds)
    echoSection "compile openh264"
    $SCRIPT_DIR/build-openh264.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" "$CPUS" > "$LOG_DIR/build-openh264.log" 2>&1
    checkStatus $? "build openh264"
    echoDurationInSections $START_TIME
    FFMPEG_LIB_FLAGS="$FFMPEG_LIB_FLAGS --enable-libopenh264"
    echo "NO" > "$LOG_DIR/skip-openh264"
else
    echoSection "skip openh264"
    echo "YES" > "$LOG_DIR/skip-openh264"
fi

if [ $SKIP_RAV1E = "NO" ]; then
    START_TIME=$(currentTimeInSeconds)
    echoSection "compile rav1e"
    $SCRIPT_DIR/build-rav1e.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" "$CPUS" > "$LOG_DIR/build-rav1e.log" 2>&1
    checkStatus $? "build rav1e"
    echoDurationInSections $START_TIME
    FFMPEG_LIB_FLAGS="$FFMPEG_LIB_FLAGS --enable-librav1e"
    echo "NO" > "$LOG_DIR/skip-rav1e"
else
    echoSection "skip rav1e"
    echo "YES" > "$LOG_DIR/skip-rav1e"
fi

if [ $SKIP_SVT_AV1 = "NO" ]; then
    START_TIME=$(currentTimeInSeconds)
    echoSection "compile svt-av1"
    $SCRIPT_DIR/build-svt-av1.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" "$CPUS" > "$LOG_DIR/build-svt-av1.log" 2>&1
    checkStatus $? "build svt-av1"
    echoDurationInSections $START_TIME
    FFMPEG_LIB_FLAGS="$FFMPEG_LIB_FLAGS --enable-libsvtav1"
    echo "NO" > "$LOG_DIR/skip-svt-av1"
else
    echoSection "skip svt-av1"
    echo "YES" > "$LOG_DIR/skip-svt-av1"
fi

if [ $SKIP_VPX = "NO" ]; then
    START_TIME=$(currentTimeInSeconds)
    echoSection "compile vpx"
    $SCRIPT_DIR/build-vpx.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" "$CPUS" > "$LOG_DIR/build-vpx.log" 2>&1
    checkStatus $? "build vpx"
    echoDurationInSections $START_TIME
    FFMPEG_LIB_FLAGS="$FFMPEG_LIB_FLAGS --enable-libvpx"
    echo "NO" > "$LOG_DIR/skip-vpx"
else
    echoSection "skip vpx"
    echo "YES" > "$LOG_DIR/skip-vpx"
fi

if [ $SKIP_X264 = "NO" ]; then
    START_TIME=$(currentTimeInSeconds)
    echoSection "compile x264"
    $SCRIPT_DIR/build-x264.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" "$CPUS" > "$LOG_DIR/build-x264.log" 2>&1
    checkStatus $? "build x264"
    echoDurationInSections $START_TIME
    FFMPEG_LIB_FLAGS="$FFMPEG_LIB_FLAGS --enable-libx264"
    echo "NO" > "$LOG_DIR/skip-x264"
else
    echoSection "skip x264"
    echo "YES" > "$LOG_DIR/skip-x264"
fi

if [ $SKIP_X265 = "NO" ]; then
    START_TIME=$(currentTimeInSeconds)
    echoSection "compile x265"
    $SCRIPT_DIR/build-x265.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" "$CPUS" "$SKIP_X265_MULTIBIT" > "$LOG_DIR/build-x265.log" 2>&1
    checkStatus $? "build x265"
    echoDurationInSections $START_TIME
    FFMPEG_LIB_FLAGS="$FFMPEG_LIB_FLAGS --enable-libx265"
    echo "NO" > "$LOG_DIR/skip-x265"
else
    echoSection "skip x265"
    echo "YES" > "$LOG_DIR/skip-x265"
fi

if [ $SKIP_LAME = "NO" ]; then
    START_TIME=$(currentTimeInSeconds)
    echoSection "compile lame (mp3)"
    $SCRIPT_DIR/build-lame.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" "$CPUS" > "$LOG_DIR/build-lame.log" 2>&1
    checkStatus $? "build lame"
    echoDurationInSections $START_TIME
    FFMPEG_LIB_FLAGS="$FFMPEG_LIB_FLAGS --enable-libmp3lame"
    echo "NO" > "$LOG_DIR/skip-lame"
else
    echoSection "skip lame (mp3)"
    echo "YES" > "$LOG_DIR/skip-lame"
fi

if [ $SKIP_OPUS = "NO" ]; then
    START_TIME=$(currentTimeInSeconds)
    echoSection "compile opus"
    $SCRIPT_DIR/build-opus.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" "$CPUS" > "$LOG_DIR/build-opus.log" 2>&1
    checkStatus $? "build opus"
    echoDurationInSections $START_TIME
    FFMPEG_LIB_FLAGS="$FFMPEG_LIB_FLAGS --enable-libopus"
    echo "NO" > "$LOG_DIR/skip-opus"
else
    echoSection "skip opus"
    echo "YES" > "$LOG_DIR/skip-opus"
fi

if [ $SKIP_LIBVORBIS = "NO" ]; then
    START_TIME=$(currentTimeInSeconds)
    echoSection "compile libvorbis"
    $SCRIPT_DIR/build-libvorbis.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" "$CPUS" > "$LOG_DIR/build-libvorbis.log" 2>&1
    checkStatus $? "build libvorbis"
    echoDurationInSections $START_TIME
    FFMPEG_LIB_FLAGS="$FFMPEG_LIB_FLAGS --enable-libvorbis"
    echo "NO" > "$LOG_DIR/skip-libvorbis"
else
    echoSection "skip libvorbis"
    echo "YES" > "$LOG_DIR/skip-libvorbis"
fi

if [ $SKIP_LIBTHEORA = "NO" ]; then
    START_TIME=$(currentTimeInSeconds)
    echoSection "compile libtheora"
    $SCRIPT_DIR/build-libtheora.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" "$CPUS" > "$LOG_DIR/build-libtheora.log" 2>&1
    checkStatus $? "build libtheora"
    echoDurationInSections $START_TIME
    FFMPEG_LIB_FLAGS="$FFMPEG_LIB_FLAGS --enable-libtheora"
    echo "NO" > "$LOG_DIR/skip-libtheora"
else
    echoSection "skip libtheora"
    echo "YES" > "$LOG_DIR/skip-libtheora"
fi

START_TIME=$(currentTimeInSeconds)
echoSection "compile ffmpeg"
$SCRIPT_DIR/build-ffmpeg.sh "$SCRIPT_DIR" "$SOURCE_DIR" "$TOOL_DIR" "$OUT_DIR" "$CPUS" "$FFMPEG_SNAPSHOT" "$FFMPEG_LIB_FLAGS" > "$LOG_DIR/build-ffmpeg.log" 2>&1
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
    $TEST_DIR/test.sh "$SCRIPT_DIR" "$TEST_DIR" "$TEST_OUT_DIR" "$OUT_DIR" "$LOG_DIR" > "$LOG_DIR/test.log" 2>&1
    checkStatus $? "test"
    echo "tests executed successfully"
    echoDurationInSections $START_TIME
fi
