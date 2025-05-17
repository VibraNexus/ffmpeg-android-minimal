#!/usr/bin/env bash
set -xe

# ==============================================================================
# build-audio-convertor-ffmpeg.sh
#
# Builds minimal FFmpeg .so libraries for Android audio conversion,
# with support for both 4 KB and 16 KB page-size devices.
#
# Prerequisites:
#   • ANDROID_NDK_ROOT must point to your Android NDK install
#   • git, make, clang available in PATH
#
# Usage:
#   chmod +x build-audio-convertor-ffmpeg.sh
#   ./build-audio-convertor-ffmpeg.sh
# ==============================================================================

# 1. Environment checks
: "${ANDROID_NDK_ROOT:?ERROR: ANDROID_NDK_ROOT is not set}"
: "${FFMPEG_SRC_DIR:=ffmpeg}"      # FFmpeg source checkout dir
: "${API:=24}"                     # Android API level
ABIS=(arm64-v8a)                   # Add other ABIs here if needed

# 2. Clone FFmpeg if missing
if [ ! -d "$FFMPEG_SRC_DIR" ]; then
  echo "Cloning FFmpeg source..."
  git clone https://github.com/FFmpeg/FFmpeg.git "$FFMPEG_SRC_DIR"
fi

# 3. Build per ABI
for ABI in "${ABIS[@]}"; do
  echo "======================================"
  echo " Building for ABI: $ABI (API $API)"
  echo "======================================"

  BUILD_DIR="$(pwd)/android-build/$ABI"
  mkdir -p "$BUILD_DIR"
  pushd "$FFMPEG_SRC_DIR"

  # Configure Android NDK toolchain paths
  # NOTE: NDK r25+ uses "linux-x86_64" as the prebuilt host folder
  TOOLCHAIN="$ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64"
  SYSROOT="$TOOLCHAIN/sysroot"

  case "$ABI" in
    arm64-v8a)
      TARGET_HOST=aarch64-linux-android
      ARCH=aarch64
      CPU=armv8-a
      ;;
    armeabi-v7a)
      TARGET_HOST=armv7a-linux-androideabi
      ARCH=arm
      CPU=armv7-a
      ;;
    # add more ABIs here...
  esac

  # Point every tool at the NDK's LLVM toolchain
  export CC="$TOOLCHAIN/bin/${TARGET_HOST}${API}-clang"
  export CXX="$TOOLCHAIN/bin/${TARGET_HOST}${API}-clang++"
  export AR="$TOOLCHAIN/bin/llvm-ar"
  export LD="$TOOLCHAIN/bin/ld.lld"
  export NM="$TOOLCHAIN/bin/llvm-nm"
  export STRIP="$TOOLCHAIN/bin/llvm-strip"
  export RANLIB="$TOOLCHAIN/bin/llvm-ranlib"

  CROSS_PREFIX="$TOOLCHAIN/bin/${TARGET_HOST}-"

  # 4. Configure FFmpeg
  ./configure \
    --prefix="$BUILD_DIR" \
    --target-os=android \
    --arch="$ARCH" \
    --cpu="$CPU" \
    --enable-cross-compile \
    --cross-prefix="$CROSS_PREFIX" \
    --sysroot="$SYSROOT" \
    --cc="$CC" \
    --cxx="$CXX" \
    --ar="$AR" \
    --nm="$NM" \
    --ld="$LD" \
    --strip="$STRIP" \
    --ranlib="$RANLIB" \
    --disable-everything \
    --enable-small \
    --enable-protocol=file \
    --enable-decoder=opus,vorbis,aac \
    --enable-encoder=mp3,flac,aac \
    --enable-demuxer=webm,matroska,ogg \
    --enable-muxer=mp3,flac,ipod \
    --extra-ldflags="-Wl,-z,max-page-size=16384"

  # 5. Build & install
  make -j"$(nproc)"
  make install

  popd
done

# 6. Collect outputs
echo "Collecting .so files into output/ directory..."
rm -rf output && mkdir -p output
for ABI in "${ABIS[@]}"; do
  mkdir -p "output/$ABI"
  cp "android-build/$ABI/lib/"*.so "output/$ABI/"
done

echo "✅ Build complete — find your .so files under output/"
