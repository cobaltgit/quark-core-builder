#!/bin/sh

. /scripts/env.sh

cd /tmp

git clone --recursive https://github.com/notaz/pcsx_rearmed.git pcsx_rearmed
cd pcsx_rearmed
git apply /scripts/custom/patches/pcsx_rearmed_trimuismart.patch

export CFLAGS="-Ofast --sysroot=$SYSROOT \
    -mcpu=cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard \
    -marm \
    -pipe \
    -fno-stack-protector \
    -fno-pic \
    -fno-common \
    -fno-ident \
    -fno-plt \
    -funroll-loops \
    -frename-registers \
    -fsection-anchors \
    -fsched-pressure \
    -fipa-pta \
    -fipa-cp \
    -fipa-cp-clone \
    -findirect-inlining \
    -fprefetch-loop-arrays \
    -falign-functions=16 \
    -falign-loops=16 \
    -ffunction-sections \
    -fdata-sections \
    -fuse-linker-plugin \
    -flto=auto"

export LDFLAGS="--sysroot=$SYSROOT -L$SYSROOT/usr/lib \
    -Wl,--gc-sections \
    -Wl,--strip-all \
    -Wl,--as-needed \
    -Wl,--allow-multiple-definition \
    -Wl,-O1 \
    -fuse-linker-plugin \
    -flto=auto"

CFLAGS="$CFLAGS -DMIYOO" ./configure \
    --disable-dynamic \
    --enable-threads \
    --enable-neon \
    --gpu=neon \
    --dynarec=ari64 \
    --sound-drivers="sdl"

make -j$(nproc)

mkdir -p /output/pcsx/lib

${CROSS}-strip --strip-all pcsx

cp pcsx /output/pcsx/
cp -r frontend/320240/skin/ /output/pcsx/
cp $SYSROOT/usr/lib/libpng16.so.16 /output/pcsx/lib/
