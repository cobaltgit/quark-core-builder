# A30 buildroot toolchain — GCC 13.2.0, glibc 2.23 sysroot.
# Matches glibc floor for A30 and Miyoo Mini devices.

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    pkg-config \
    git \
    ca-certificates \
    wget \
    zip \
    cmake \
    curl \
    clang \
    meson \
    rsync \
    && rm -rf /var/lib/apt/lists/*

# Install A30 buildroot toolchain (downloaded from toolchains release at build time)
ADD https://github.com/spruceUI/Cores-spruce/releases/download/toolchains/a30_toolchain-v1.0.tar.gz /tmp/
RUN tar xzf /tmp/a30_toolchain-v1.0.tar.gz -C /opt && rm /tmp/a30_toolchain-v1.0.tar.gz

# Create toolchain wrapper scripts (buildroot wrappers weren't included in tarball)
RUN SYSROOT=/opt/a30/arm-a30-linux-gnueabihf/sysroot && \
    rm -f /opt/a30/bin/arm-a30-linux-gnueabihf-gcc /opt/a30/bin/arm-a30-linux-gnueabihf-g++ && \
    printf '#!/bin/sh\nexec /opt/a30/bin/arm-a30-linux-gnueabihf-gcc-13.2.0.br_real --sysroot=%s "$@"\n' "$SYSROOT" > /opt/a30/bin/arm-a30-linux-gnueabihf-gcc && \
    printf '#!/bin/sh\nexec /opt/a30/bin/arm-a30-linux-gnueabihf-c++.br_real --sysroot=%s "$@"\n' "$SYSROOT" > /opt/a30/bin/arm-a30-linux-gnueabihf-g++ && \
    chmod +x /opt/a30/bin/arm-a30-linux-gnueabihf-gcc /opt/a30/bin/arm-a30-linux-gnueabihf-g++

# Create cross pkg-config wrapper
RUN SYSROOT=/opt/a30/arm-a30-linux-gnueabihf/sysroot && \
    printf '#!/bin/sh\nexport PKG_CONFIG_SYSROOT_DIR=%s\nexport PKG_CONFIG_LIBDIR=%s/usr/lib/pkgconfig\nexec pkg-config "$@"\n' \
    "$SYSROOT" "$SYSROOT" > /opt/a30/bin/arm-a30-linux-gnueabihf-pkg-config && \
    chmod +x /opt/a30/bin/arm-a30-linux-gnueabihf-pkg-config

# Restore sysroot/lib symlinks stripped by tarball
RUN SYSROOT=/opt/a30/arm-a30-linux-gnueabihf/sysroot && \
    cd "$SYSROOT/lib" && \
    ln -sf ld-2.23.so ld-linux-armhf.so.3 && \
    ln -sf libc-2.23.so libc.so.6 && \
    ln -sf libpthread-2.23.so libpthread.so.0 && \
    ln -sf libdl-2.23.so libdl.so.2 && \
    ln -sf libm-2.23.so libm.so.6 && \
    ln -sf librt-2.23.so librt.so.1 && \
    ln -sf libresolv-2.23.so libresolv.so.2 && \
    ln -sf libnsl-2.23.so libnsl.so.1

# Update kernel headers (fixes pcsx_rearmed compilation)
ADD https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.15.158.tar.xz /tmp/linux-5.15.158.tar.xz
RUN tar -xf /tmp/linux-5.15.158.tar.xz -C /tmp && \
    rm /tmp/linux-5.15.158.tar.xz && \
    cd /tmp/linux-5.15.158 && \
    make ARCH=arm CROSS_COMPILE=arm-a30-linux-gnueabihf- headers_install INSTALL_HDR_PATH=/opt/a30/arm-a30-linux-gnueabihf/sysroot/usr && \
    rm -rf /tmp/linux-5.15.158

# Clone libretro-super build system
RUN git clone --depth 1 https://github.com/libretro/libretro-super.git /libretro-super

ENV HOST_CC=arm-a30-linux-gnueabihf
ENV PATH="/opt/a30/bin:${PATH}"

WORKDIR /libretro-super

COPY scripts /scripts

ENTRYPOINT [ "/scripts/build-super.sh" ]
