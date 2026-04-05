#!/bin/sh

# A30 buildroot toolchain
export TOOLCHAIN=/opt/a30
export SYSROOT=$TOOLCHAIN/arm-a30-linux-gnueabihf/sysroot
export CROSS=arm-a30-linux-gnueabihf

export PATH="$TOOLCHAIN/bin:$PATH"
export CC="${CROSS}-gcc"
export CXX="${CROSS}-g++"
export AR="${CROSS}-gcc-ar"
export RANLIB="${CROSS}-gcc-ranlib"
export NM="${CROSS}-gcc-nm"
export STRIP="${CROSS}-strip"
export PKG_CONFIG_PATH="$SYSROOT/usr/lib/pkgconfig"
export PKG_CONFIG_LIBDIR="$SYSROOT/usr/lib/pkgconfig"
export PKG_CONFIG_SYSROOT_DIR="$SYSROOT"
export CFLAGS="-Ofast --sysroot=$SYSROOT -mcpu=cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard -ffast-math -fomit-frame-pointer -fuse-linker-plugin -ffunction-sections -fdata-sections -flto=auto"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="--sysroot=$SYSROOT -L$SYSROOT/usr/lib -Wl,--gc-sections,--strip-all -static-libstdc++ -fuse-linker-plugin -flto=auto"

export CMAKE_PREFIX_PATH="$SYSROOT/usr"

export platform="linux-armv7-neon"
