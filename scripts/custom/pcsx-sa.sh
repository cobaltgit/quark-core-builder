#!/bin/sh

. /scripts/env.sh

cd /tmp

git clone --recursive https://github.com/notaz/pcsx_rearmed.git pcsx_rearmed
cd pcsx_rearmed
git apply /scripts/custom/patches/pcsx_rearmed_trimuismart.patch

CFLAGS="$CFLAGS -DMIYOO" ./configure \
    --disable-dynamic \
    --enable-threads \
    --enable-neon \
    --gpu=neon \
    --dynarec=ari64 \
    --sound-drivers="sdl"

make -j$(nproc)

mkdir -p /output/pcsx/lib

cp pcsx /output/pcsx/
cp -r frontend/320240/skin/ /output/pcsx/
cp $SYSROOT/usr/lib/libpng16.so.16 /output/pcsx/lib/
