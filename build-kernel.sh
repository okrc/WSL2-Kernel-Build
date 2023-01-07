#!/usr/bin/env bash
set -e

VERSION_CODENAME=$(grep -Po '(?<=VERSION_CODENAME=)[[:alpha:]]+' /etc/os-release)

apt-get update && apt-get install --no-install-recommends --yes curl ca-certificates gpg xz-utils make flex bison libssl-dev libelf-dev bc python3-minimal dwarves tzdata

curl -fsSL https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor \
    -o /usr/share/keyrings/llvm-apt-archive-keyring.gpg
echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/llvm-apt-archive-keyring.gpg] \
https://apt.llvm.org/${VERSION_CODENAME} llvm-toolchain-${VERSION_CODENAME} main
# deb-src [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/llvm-apt-archive-keyring.gpg] \
https://apt.llvm.org/${VERSION_CODENAME} llvm-toolchain-${VERSION_CODENAME} main" | tee /etc/apt/sources.list.d/llvm-apt.list >/dev/null

apt-get update && apt-get install --no-install-recommends --yes clang lld llvm

if [ ! -f 'kernel.tar.xz' ]; then
    KERNEL_URL=https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.1.4.tar.xz
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
    (cd $TMPDIR && make -j$(nproc) ARCH=x86_64 LLVM=1)
    cp $TMPDIR/arch/x86/boot/bzImage ./wsl2-kernel-amd64
    sha256sum wsl2-kernel-amd64 >./wsl2-kernel-amd64.sha256
}

build_arm64_kernel() {
    build_config config-wsl-arm64
    (cd $TMPDIR && make -j$(nproc) ARCH=arm64 LLVM=1)
    cp $TMPDIR/arch/arm64/boot/Image ./wsl2-kernel-arm64
    sha256sum wsl2-kernel-arm64 >./wsl2-kernel-arm64.sha256
}

build_amd64_kernel
build_arm64_kernel

rm -rf $TMPDIR config-wsl{,-arm64} /var/lib/apt/lists/
