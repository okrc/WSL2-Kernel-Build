#!/usr/bin/env bash
set -e

if [ ! -f 'kernel.tar.xz' ]; then
    KERNEL_URL=https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.1.12.tar.xz
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
    (
        cd $TMPDIR

        set +e
        RUSTC_VERSION=$(echo ${RUSTC_VERSION:-$(scripts/min-tool-version.sh rustc 2>/dev/null)} | grep -Po '^([[:digit:]]{1,3}\.){1,2}[[:digit:]]{1,3}$')
        set -e

        if [ ! -z ${RUSTC_VERSION} ]; then
            sh <(curl -fsSL https://sh.rustup.rs) --quiet -y --default-toolchain $(scripts/min-tool-version.sh rustc) --profile minimal --component rust-src
            . "$HOME/.cargo/env"
            cargo install --locked --version $(scripts/min-tool-version.sh bindgen) bindgen
            make LLVM=-${LLVM_VERSION} rustavailable
        fi

        make -j$(nproc) ARCH=x86_64 LLVM=-${LLVM_VERSION}
    )
    cp $TMPDIR/arch/x86/boot/bzImage ./wsl2-kernel-amd64
    sha256sum wsl2-kernel-amd64 >./wsl2-kernel-amd64.sha256
}

build_arm64_kernel() {
    build_config config-wsl-arm64
    (cd $TMPDIR && make -j$(nproc) ARCH=arm64 LLVM=-${LLVM_VERSION})
    cp $TMPDIR/arch/arm64/boot/Image ./wsl2-kernel-arm64
    sha256sum wsl2-kernel-arm64 >./wsl2-kernel-arm64.sha256
}

build_amd64_kernel
build_arm64_kernel

rm -rf $TMPDIR config-wsl{,-arm64} /var/lib/apt/lists/
