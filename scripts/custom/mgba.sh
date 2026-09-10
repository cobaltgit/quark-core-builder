#!/bin/bash
# Builder for mGBA libretro core

set -e

. /scripts/env.sh

CORE_REPO="https://github.com/libretro/mgba.git"
SRC_DIR="/tmp/mgba"
BUILD_DIR="/tmp/mgba-build"
TOOLCHAIN_FILE="/tmp/a30-arm-toolchain.cmake"

ARCH_FLAGS="-O3 -mcpu=cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard \
-fomit-frame-pointer -ffunction-sections -fdata-sections -ffast-math \
-fuse-linker-plugin -flto=auto"

# Write a CMake toolchain file
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
# Never search the host system for programs (would pick up native tools)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# Bake arch flags into the initial cache so every vendored sub-project
# inherits them through ExternalProject / add_subdirectory.
set(CMAKE_C_FLAGS_INIT   "${ARCH_FLAGS}" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS_INIT "${ARCH_FLAGS}" CACHE STRING "" FORCE)
EOF

# Build time!
echo "Cloning mGBA..."
git clone --depth 1 --recursive "$CORE_REPO" "$SRC_DIR"

echo "Configuring..."
cmake "$SRC_DIR" -B "$BUILD_DIR" -GNinja \
    -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN_FILE" \
    -DCMAKE_BUILD_TYPE=Release \
    -DLIBMGBA_ONLY=ON \
    -DBUILD_LIBRETRO=ON \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DCMAKE_SHARED_LINKER_FLAGS="$LDFLAGS"

echo "Building ($(nproc) jobs)..."
cmake --build "$BUILD_DIR" \
    -- -j"$(nproc)"

cp "$BUILD_DIR/mgba_libretro.so" /output/cores/mgba_libretro.so
cp "/libretro-super/dist/info/mgba_libretro.info" /output/core_info/mgba_libretro.info

# Cleanup
rm -rf "$SRC_DIR" "$BUILD_DIR" "$TOOLCHAIN_FILE"
echo "Done!"
