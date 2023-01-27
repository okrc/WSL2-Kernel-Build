FROM ubuntu:latest
ENV LLVM_VERSION=15
RUN . /etc/os-release; \
    apt-get update && apt-get install --no-install-recommends --yes curl ca-certificates gpg xz-utils make flex bison libssl-dev libelf-dev bc python3-minimal dwarves tzdata; \
    curl -fsSL https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor -o /usr/share/keyrings/llvm-apt-archive-keyring.gpg; \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/llvm-apt-archive-keyring.gpg] \
    https://apt.llvm.org/${VERSION_CODENAME} llvm-toolchain-${VERSION_CODENAME}-${LLVM_VERSION} main" | \
    tee /etc/apt/sources.list.d/llvm-apt.list >/dev/null; \
    apt-get update && apt-get install --no-install-recommends --yes clang-${LLVM_VERSION} lld-${LLVM_VERSION} llvm-${LLVM_VERSION}; \
    update-alternatives --install /usr/bin/cc cc /usr/bin/clang-${LLVM_VERSION} 100
ENV TZ=Etc/GMT-8
