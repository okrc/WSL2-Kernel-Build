#!/usr/bin/env bash
set -e

CONFIG_BRA=linux-msft-wsl-5.15.y

apt-get update && apt-get install --no-install-recommends --yes curl ca-certificates xz-utils make flex bison libssl-dev libelf-dev bc python3-minimal dwarves \
    gcc-x86-64-linux-gnu gcc-aarch64-linux-gnu

if [ ! -f 'kernel.tar.xz' ]; then
    KERNEL_URL=https://api.github.com/repos/microsoft/WSL2-Linux-Kernel/tarball/linux-msft-wsl-5.15.57.1
    curl -C- -sL ${KERNEL_URL} -o kernel.tar.xz
fi

build_amd64_kernel() {
    TMPDIR=$(mktemp -d)
    tar xf kernel.tar.xz --strip-components=1 -C $TMPDIR
    curl -s "https://raw.githubusercontent.com/microsoft/WSL2-Linux-Kernel/${CONFIG_BRA}/Microsoft/config-wsl" |
        sed -e 's/^#[[:space:]]\(CONFIG_BLK_DEV_THROTTLING\b\).*/\1=y/g' \
            -e 's/^#[[:space:]]\(CONFIG_NFT_\(COMPAT\|NAT\)\b\).*/\1=y/g' \
            -e 's/^#[[:space:]]\(CONFIG_IPV6_MULTIPLE_TABLES\b\).*/\1=y/g' \
            -e 's/^#[[:space:]]\(CONFIG_NFT_\(CT\|FIB_IPV\(4\|6\)\)\b\).*/\1=y/g' \
            >$TMPDIR/.config
    (cd $TMPDIR && make -j$(nproc) ARCH=x86_64 CROSS_COMPILE=x86_64-linux-gnu-)
    cp $TMPDIR/arch/x86/boot/bzImage ./wsl2-kernel-amd64
    sha256sum wsl2-kernel-amd64 >./wsl2-kernel-amd64.sha256
    rm -rf $TMPDIR
}

build_arm64_kernel() {
    TMPDIR=$(mktemp -d)
    tar xf kernel.tar.xz --strip-components=1 -C $TMPDIR
    curl -s "https://raw.githubusercontent.com/microsoft/WSL2-Linux-Kernel/${CONFIG_BRA}/Microsoft/config-wsl-arm64" |
        sed -e 's/^#[[:space:]]\(CONFIG_BLK_DEV_THROTTLING\b\).*/\1=y/g' \
            -e 's/^#[[:space:]]\(CONFIG_NFT_\(COMPAT\|NAT\)\b\).*/\1=y/g' \
            -e 's/^#[[:space:]]\(CONFIG_IPV6_MULTIPLE_TABLES\b\).*/\1=y/g' \
            -e 's/^#[[:space:]]\(CONFIG_NFT_\(CT\|FIB_IPV\(4\|6\)\)\b\).*/\1=y/g' \
            >$TMPDIR/.config
    (cd $TMPDIR && make -j$(nproc) ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu-)
    cp $TMPDIR/arch/arm64/boot/Image ./wsl2-kernel-arm64
    sha256sum wsl2-kernel-arm64 >./wsl2-kernel-arm64.sha256
    rm -rf $TMPDIR
}

build_amd64_kernel
build_arm64_kernel
