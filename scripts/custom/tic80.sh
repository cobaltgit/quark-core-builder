#!/bin/bash
# Builder for TIC-80 libretro core with all game interpreters for maximum compatibility

set -e

. /scripts/env.sh

# For QEMU host tools to work (janet, mrbc)
export QEMU_LD_PREFIX="$SYSROOT"

CORE_REPO="https://github.com/nesbox/TIC-80.git"
SRC_DIR="/tmp/TIC-80"
BUILD_DIR="/tmp/tic80-build"
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

# Install rake and qemu-user-static
if ! command -v rake > /dev/null 2>&1; then
    apt-get update > /dev/null
    apt-get install -y --no-install-recommends ruby > /dev/null
fi
if ! command -v qemu-arm-static > /dev/null 2>&1; then
    apt-get update > /dev/null
    apt-get install -y --no-install-recommends qemu-user-static > /dev/null
fi

# Build time!
echo "Cloning TIC-80..."
git clone --depth 1 --recursive "$CORE_REPO" "$SRC_DIR"

echo "Copying Janet config header..."
cp "$SRC_DIR/build/janet/janetconf.h" \
   "$SRC_DIR/vendor/janet/src/conf/janetconf.h"

mkdir -p "$BUILD_DIR"
echo "Configuring..."

cmake "$SRC_DIR" -B "$BUILD_DIR" \
    -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN_FILE" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    \
    -DBUILD_LIBRETRO=ON \
    -DBUILD_PLAYER=OFF \
    -DBUILD_PRO=OFF \
    -DBUILD_SDL=OFF \
    -DBUILD_TOOLS=OFF \
    -DBUILD_TOUCH_INPUT=OFF \
    -DBUILD_STATIC=ON \
    \
    -DBUILD_WITH_ALL=ON \
    \
    -DCMAKE_SHARED_LINKER_FLAGS="\
-L${SYSROOT}/usr/lib \
-Wl,--gc-sections \
-static-libstdc++ \
-fuse-linker-plugin -flto=auto"

echo "Building ($(nproc) jobs)..."
cmake --build "$BUILD_DIR" \
    --target tic80_libretro \
    --config Release \
    -- -j"$(nproc)"

cp "$BUILD_DIR/bin/tic80_libretro.so" /output/cores/tic80_libretro.so
cp "/libretro-super/dist/info/tic80_libretro.info" /output/core_info/tic80_libretro.info

# Cleanup
rm -rf "$SRC_DIR" "$BUILD_DIR" "$TOOLCHAIN_FILE"
echo "Done!"
