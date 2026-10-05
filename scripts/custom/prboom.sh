#!/bin/bash
# Build script for prboom libretro core

set -e

. "$(dirname "$0")/../env.sh"

CORE_NAME="prboom"
CORE_REPO="https://github.com/libretro/libretro-prboom"

cd /tmp
git clone --recursive "$CORE_REPO" "$CORE_NAME"
cd "$CORE_NAME"

make -j$(nproc) \
    LDFLAGS="$LDFLAGS -lrt -lm -lpthread" # force link shit

cp prboom_libretro.so "/output/cores/prboom_libretro.so"
cp /libretro-super/dist/info/prboom_libretro.info "/output/core_info/prboom_libretro.info"

cd /tmp
rm -rf "$CORE_NAME"
