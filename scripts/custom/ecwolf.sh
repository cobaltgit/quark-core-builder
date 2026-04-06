#!/bin/bash

set -e

. "$(dirname "$0")/../env.sh"

CORE_NAME="ecwolf"
CORE_REPO="https://github.com/libretro/ecwolf.git"

TOOLCHAIN_FILE="/tmp/a30-arm-toolchain.cmake"

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
set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
# Never search the host system for programs (would pick up native tools)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# Bake arch flags into the initial cache so every vendored sub-project
# inherits them through ExternalProject / add_subdirectory.
set(CMAKE_C_FLAGS_INIT   "${CFLAGS}" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS_INIT "${CXXFLAGS}" CACHE STRING "" FORCE)
set(CMAKE_EXE_SHARED_LINKER_FLAGS "${LDFLAGS}" CACHE STRING "" FORCE)
EOF

cd /tmp

git clone "$CORE_REPO" "$CORE_NAME"
cd $CORE_NAME

# manually clone submodules until libretroadmin merges that damn pr
git clone https://github.com/libretro/libretro-common.git src/libretro/libretro-common
cp src/libretro/state_machine.h src/state_machine.h

cmake -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN_FILE" -DLIBRETRO=1 .
make -j$(nproc)

cp "${CORE_NAME}_libretro.so" /output/cores
cp "/libretro-super/dist/info/${CORE_NAME}_libretro.info" /output/core_info/

cd /tmp
rm -rf "$CORE_NAME"
