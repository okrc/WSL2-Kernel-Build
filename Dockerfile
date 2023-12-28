FROM debian:stable-slim
RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends --yes curl ca-certificates gpg xz-utils make flex bison libssl-dev libelf-dev bc python3-minimal dwarves tzdata clang lld llvm; \
    update-alternatives --install /usr/bin/cc cc /usr/bin/clang 100; \
    rm -rf /var/lib/apt/lists/*
ARG TZ=Etc/GMT-8
ENV TZ=${TZ}
