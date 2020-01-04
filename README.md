# FFmpeg
This script is made to compile FFmpeg with common codecs on Linux and Mac OSX.

## Result
This repository builds ffmpeg, ffprobe and ffserver for Mac OSX and Linux using
- build tools
    - [nasm](http://www.nasm.us/)
- video codecs
    - [x264](http://www.videolan.org/developers/x264.html) for H.264 encoding
    - [libvpx](https://www.webmproject.org/) for VP8/VP9 de/encoding
- audio codecs
    - [LAME](http://lame.sourceforge.net/) for MP3 encoding

To get a full list of all formats and codecs that are supported just execute
```
./ffmpeg -formats
./ffmpeg -codecs
```

## Requirements
There are just a few dependencies to other tools. Most of the software is compiled or downloaded during script execution. Also most of the tools should be already available on the system by default.

### Required
- curl for downloading files

### Optional
- nproc (on linux) or sysctl (on Mac OSX) for multicore compilation

## Execution
To run this script simply execute the build.sh script.
```
./build.sh
```

## Folder Structure
All files that are downloaded and generated through this script are placed in the current working directory. The recommendation is to use an empty folder for this.
```
mkdir ffmpeg-compile
cd ffmpeg-compile
```

Now execute the script using:
```
../path/to/repository/build.sh
```

After the execution a new folder called "out" exists. It contains the compiled FFmpeg binary (in the bin sub-folder).
The ffmpeg-success.zip contains also all binary files of FFmpeg.

## Build failed?
Check the detailed logfiles in the working directory. Each build step has its own file starting with "build-*".
