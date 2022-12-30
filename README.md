# WSL2-Kernel-Build

[![License][1]][LICENSE]
[![BuildKernel][2]][3]
[![Release][4]][RELEASE]
[![PreRelease][5]][PRERELEASE]

## Build & install

### **Docker build**

``` sh
docker run --rm --volume ${PWD}:/prefix --workdir /prefix debian:stable-slim ./build-kernel.sh
```

### **WSLCONFIG**

``` conf
[wsl2]
kernel=C:\\Users\\okrc\\bzImage     # your path
```

[1]: https://img.shields.io/github/license/okrc/WSL2-Kernel-Build
[2]: https://img.shields.io/github/actions/workflow/status/okrc/WSL2-Kernel-Build/build-kernel.yml?branch=main
[3]: https://github.com/okrc/WSL2-Kernel-Build/actions/workflows/build-kernel.yml
[4]: https://img.shields.io/github/v/release/okrc/WSL2-Kernel-Build?display_name=release&sort=date
[5]: https://img.shields.io/github/v/release/okrc/WSL2-Kernel-Build?display_name=release&color=teal&include_prereleases&label=pre-release&sort=date

[LICENSE]: LICENSE
[RELEASE]: https://github.com/okrc/WSL2-Kernel-Build/releases/latest
[PRERELEASE]: https://github.com/okrc/WSL2-Kernel-Build/releases
[WSL2-Linux-Kernel REPO]: https://github.com/microsoft/WSL2-Linux-Kernel
[The-Linux-Kernel REPO]: https://www.kernel.org
