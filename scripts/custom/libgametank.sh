#!/bin/bash
# Builder for gametank libretro core

RUST_TARGET="armv7-unknown-linux-gnueabihf"
GLIBC="2.23"
ZIG_VERSION="0.15.2"
GAMETANK_REPO="https://github.com/dwbrite/gametank-sdk.git"

# Install rust for armv7hf
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
. "$HOME/.cargo/env"
rustup target add $RUST_TARGET

# Install zig
cd /tmp
echo "Downloading zig..."
curl -LO "https://ziglang.org/download/$ZIG_VERSION/zig-x86_64-linux-$ZIG_VERSION.tar.xz"
echo "Extracting zig tarball..."
tar -xJf "zig-x86_64-linux-$ZIG_VERSION.tar.xz" -C /usr/local
rm "zig-x86_64-linux-$ZIG_VERSION.tar.xz"
ln -s /usr/local/zig-x86_64-linux-$ZIG_VERSION/zig /usr/local/bin/zig
zig version || exit 1

# Install cargo-zigbuild
cargo install cargo-zigbuild

# Build gametank core
echo "Building gametank core..."
git clone "$GAMETANK_REPO"
cd gametank-sdk/tools/gte/libretro
cargo zigbuild --target $RUST_TARGET.$GLIBC --release
cp gametank_libretro.info /output/core_info/gametank_libretro.info
cd /tmp
cp "/tmp/gametank-sdk/target/$RUST_TARGET/release/libgametank_libretro.so" /output/cores/libgametank_libretro.so
rm -rf /tmp/gametank-sdk
echo "Done!"
