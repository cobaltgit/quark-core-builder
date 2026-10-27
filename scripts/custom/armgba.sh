#!/bin/bash

set -e

. "$(dirname "$0")/../env.sh"

CORE_NAME="armgba"
CORE_REPO="https://github.com/Jacob-Matthew-Cook/armGBA.git"
BUILD_DIR="/tmp/$CORE_NAME-build"
TOOLCHAIN_FILE="/tmp/$CORE_NAME-toolchain.cmake"

echo "Writing CMake toolchain file: $TOOLCHAIN_FILE"
cat > "$TOOLCHAIN_FILE" << EOF
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)

set(CMAKE_C_COMPILER   ${CROSS}-gcc)
set(CMAKE_CXX_COMPILER ${CROSS}-g++)
set(CMAKE_AR           ${CROSS}-gcc-ar   CACHE FILEPATH "" FORCE)
set(CMAKE_RANLIB       ${CROSS}-gcc-ranlib CACHE FILEPATH "" FORCE)
set(CMAKE_STRIP        ${CROSS}-strip    CACHE FILEPATH "" FORCE)

set(CMAKE_SYSROOT      ${SYSROOT})
set(CMAKE_FIND_ROOT_PATH ${SYSROOT})
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
EOF

cd /tmp
rm -rf "$CORE_NAME"
git clone "$CORE_REPO" "$CORE_NAME"

cd "$CORE_NAME"

cmake -S . -B "$BUILD_DIR" -G Ninja -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN_FILE" \
    -DCMAKE_C_FLAGS="-mcpu=cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard -ffast-math -fomit-frame-pointer -ffunction-sections -fdata-sections" \
    -DCMAKE_CXX_FLAGS="-mcpu=cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard -ffast-math -fomit-frame-pointer -ffunction-sections -fdata-sections" \
    -DCMAKE_SHARED_LINKER_FLAGS="-Wl,--gc-sections -Wl,--as-needed -Wl,--strip-all -Wl,-O1 -static-libstdc++" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INTERPROCEDURAL_OPTIMIZATION=ON
cmake --build "$BUILD_DIR"

cp "$BUILD_DIR/${CORE_NAME}_libretro.so" /output/cores
cp "libretro/${CORE_NAME}_libretro.info" /output/core_info

cd /tmp
rm -rf "$CORE_NAME"
