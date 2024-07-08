FROM buildpack-deps:curl
ARG LLVM_VERSION=14
ENV LLVM_VERSION=${LLVM_VERSION}
ARG TZ=Etc/GMT-8
ENV TZ=${TZ}
RUN set -eux; \
    # curl -fsSL https://apt.llvm.org/llvm-snapshot.gpg.key | \
    # gpg --dearmor -o /usr/share/keyrings/llvm-apt-archive-keyring.gpg; \
    # . /etc/os-release; \
    # echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/llvm-apt-archive-keyring.gpg] \
    # https://apt.llvm.org/$VERSION_CODENAME llvm-toolchain-$VERSION_CODENAME-$LLVM_VERSION main" | \
    # tee /etc/apt/sources.list.d/llvm-apt.list >/dev/null; \
    apt-get update; \
    apt-get install --no-install-recommends --yes \
    xz-utils make flex bison libssl-dev libelf-dev bc python3-minimal dwarves tzdata cpio clang-${LLVM_VERSION} lld-${LLVM_VERSION} llvm-${LLVM_VERSION}; \
    update-alternatives --install /usr/bin/cc cc /usr/bin/clang-$LLVM_VERSION 100; \
    rm -rf /var/lib/apt/lists/*
