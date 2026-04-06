#!/bin/bash

set -e

. "$(dirname "$0")/../env.sh"

CORE_NAME="dosbox_pure"
CORE_REPO="https://github.com/schellingb/dosbox-pure.git"

cd /tmp
git clone "$CORE_REPO" "$CORE_NAME"

cd "$CORE_NAME"
make -j$(nproc) MAKE_CPUFLAGS="$CXXFLAGS" \
    LDFLAGS="$LDFLAGS -shared" \
    STRIPCMD="true"

cp "${CORE_NAME}_libretro.so" /output/cores
cp "${CORE_NAME}_libretro.info" /output/core_info

cd /tmp
rm -rf "$CORE_NAME"
