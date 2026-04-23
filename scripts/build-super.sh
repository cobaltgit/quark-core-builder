#!/bin/bash
# Build script for RetroArch cores on Quark using libretro-super
# Runs custom build scripts in /scripts/custom

set -e

. "$(dirname "$0")/env.sh"

OUTPUT_DIR=${OUTPUT_DIR:-/output}

mkdir -p "$OUTPUT_DIR/cores" "$OUTPUT_DIR/core_info"

RUN git clone --depth 1 https://github.com/libretro/libretro-super.git .

for core in $CORES; do
    echo "Building: $core"
    if [ -f "/scripts/custom/$core.sh" ]; then
        # use custom build script instead of libretro-super
        bash -e "/scripts/custom/$core.sh"
        continue
    fi
    ./libretro-fetch.sh "$core"
    ./libretro-build.sh "$core"
    cp dist/unix/"${core}_libretro.so" "$OUTPUT_DIR/cores/"
    cp dist/info/"${core}_libretro.info" "$OUTPUT_DIR/core_info/"
done
