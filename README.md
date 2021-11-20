# FFmpeg
This script is made to compile FFmpeg with common codecs on Linux and Mac OSX.

## Result
This repository builds FFmpeg, FFprobe and FFplay for Linux and Mac OSX using
- build tools
    - [cmake](https://cmake.org/)
    - [nasm](http://www.nasm.us/)
    - [pkg-config](https://www.freedesktop.org/wiki/Software/pkg-config/)
- libraries
    - [FreeType](https://freetype.org)
    - [openssl](https://www.openssl.org/)
    - [SDL](https://www.libsdl.org/)
- video codecs
    - [aom](https://aomedia.org/) for AV1 de-/encoding
    - [openh264](https://www.openh264.org/) for H.264 de-/encoding
    - [x264](http://www.videolan.org/developers/x264.html) for H.264 encoding
    - [x265](https://www.videolan.org/developers/x265.html) for H.265/HEVC encoding
    - [vpx](https://www.webmproject.org/) for VP8/VP9 de-/encoding
- audio codecs
    - [LAME](http://lame.sourceforge.net/) for MP3 encoding
    - [opus](https://opus-codec.org/) for Opus de-/encoding

To get a full list of all formats and codecs that are supported just execute
```
./ffmpeg -formats
./ffmpeg -codecs
```

## Requirements
There are just a few dependencies to other tools. Most of the software is compiled or downloaded during script execution. Also most of the tools should be already available on the system by default.

### Required
- c and c++ compiler like AppleClang (included in Xcode) or gcc (on Linux)
- curl for downloading files
- git
- make
- zip, bunzip2

### Optional
- nproc (on linux) or sysctl (on Mac OSX) for multicore compilation

## Execution
All files that are downloaded and generated through this script are placed in the current working directory. The recommendation is to use an empty folder for this and execute the `build.sh`.
```sh
mkdir ffmpeg-compile
cd ffmpeg-compile
../build.sh
```

You can use the following parameters
- `-FFMPEG_SNAPSHOT=YES` for using the latest snapshot of FFmpeg instead of the last release
- `-SKIP_TEST=YES` for skipping the tests after compiling
- `-CPU_LIMIT=num` for limit CPU thread usage (default: automatically detected)

After the execution a new folder called `out` exists. It contains the compiled FFmpeg binary (in the `bin` sub-folder).
The `ffmpeg-success.zip` contains also all binary files of FFmpeg, FFprobe and FFplay.

## Build failed?
Check the detailed logfiles in the `log` directory. Each build step has its own file starting with "build-*".

If the build of ffmpeg failes during the configuration phase (e.g. because it doesn't find one codec) check also the log file in `source/ffmpeg/ffmpeg-*/ffbuild/config.log`.
