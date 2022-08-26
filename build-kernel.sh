#!/usr/bin/env bash
set -e

apt-get update && apt-get install --no-install-recommends --yes curl ca-certificates xz-utils make flex bison libssl-dev libelf-dev bc python3-minimal dwarves \
    gcc-x86-64-linux-gnu gcc-aarch64-linux-gnu

if [ ! -f 'kernel.tar.xz' ]; then
    KERNEL_URL=https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.19.4.tar.xz
    curl -C- -sL ${KERNEL_URL} -o kernel.tar.xz
fi

TMPDIR=$(mktemp -d)
tar xf kernel.tar.xz --strip-components=1 -C $TMPDIR
curl --silent --remote-name-all https://raw.githubusercontent.com/microsoft/WSL2-Linux-Kernel/linux-msft-wsl-5.15.y/Microsoft/config-wsl{,-arm64}

build_config() {
    if [ -f "$1" ]; then
        sed -e 's/^#[[:space:]]\(CONFIG_BLK_DEV_THROTTLING\b\).*/\1=y/g' \
            -e 's/^#[[:space:]]\(CONFIG_IPV6_MULTIPLE_TABLES\b\).*/\1=y/g' \
            -e 's/^#[[:space:]]\(CONFIG_NFT_FIB_IPV4\b\).*/\1=y/g' \
            -e 's/^#[[:space:]]\(CONFIG_NFT_FIB_IPV6\b\).*/\1=y/g' \
            -e "w $TMPDIR/.config" \
            "$1" >/dev/null
    fi
}

build_amd64_kernel() {
    build_config config-wsl
    (cd $TMPDIR && make -j$(nproc) ARCH=x86_64 CROSS_COMPILE=x86_64-linux-gnu-)
    cp $TMPDIR/arch/x86/boot/bzImage ./wsl2-kernel-amd64
    sha256sum wsl2-kernel-amd64 >./wsl2-kernel-amd64.sha256
}

build_arm64_kernel() {
    build_config config-wsl-arm64
    (cd $TMPDIR && make -j$(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu-)
    cp $TMPDIR/arch/arm64/boot/Image ./wsl2-kernel-arm64
    sha256sum wsl2-kernel-arm64 >./wsl2-kernel-arm64.sha256
}

build_amd64_kernel
build_arm64_kernel

rm -rf $TMPDIR config-wsl{,-arm64}
