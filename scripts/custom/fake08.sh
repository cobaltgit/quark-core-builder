#!/bin/bash
# Build script for fake08 libretro core

set -e

. "$(dirname "$0")/../env.sh"

CORE_NAME="fake08"
CORE_REPO="https://github.com/jtothebell/fake-08.git"

cd /tmp
git clone --recursive "$CORE_REPO" "$CORE_NAME"
cd "$CORE_NAME/platform/libretro"

make -j$(nproc) \
    CXXFLAGS="$CXXFLAGS -fPIC" \
    LDFLAGS="$LDFLAGS -fPIC"

cp fake08_libretro.dll "/output/cores/fake08_libretro.so" # why does it save as a .dll? guess we'll never know
cp fake08_libretro.info "/output/core_info/fake08_libretro.info"

cd /tmp
rm -rf "$CORE_NAME"
