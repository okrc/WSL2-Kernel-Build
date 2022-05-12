# WSL2-Kernel-Build

[![License][1]][LICENSE]
[![BuildKernel][2]][3]
[![Download][4]][PRERELEASE]  
[![Release][5]][RELEASE]
[![ReleaseDate][7]][RELEASE]  
[![PreRelease][6]][PRERELEASE]
[![PreReleaseDate][8]][PRERELEASE]

## Build & install

### **Docker build**

``` sh
docker run --rm --volume ${PWD}:/prefix --workdir /prefix debian:testing-slim bash ./build-kernel.sh
```

### **WSLCONFIG**

``` conf
[wsl2]
kernel=C:\\Users\\okrc\\bzImage     # your path
```

[1]: https://img.shields.io/github/license/okrc/WSL2-Kernel-Build
[2]: https://img.shields.io/github/workflow/status/okrc/WSL2-Kernel-Build/Build%20kernel?label=Build%20kernel
[3]: https://github.com/okrc/WSL2-Kernel-Build/actions/workflows/build-kernel.yml
[4]: https://img.shields.io/github/downloads/okrc/WSL2-Kernel-Build/total
[5]: https://img.shields.io/github/v/release/okrc/WSL2-Kernel-Build?display_name=release&sort=date
[6]: https://img.shields.io/github/v/release/okrc/WSL2-Kernel-Build?display_name=release&include_prereleases&label=pre-release&sort=date
[7]: https://img.shields.io/github/release-date/okrc/WSL2-Kernel-Build
[8]: https://img.shields.io/github/release-date-pre/okrc/WSL2-Kernel-Build?label=pre-release-date

[LICENSE]: LICENSE
[RELEASE]: https://github.com/okrc/WSL2-Kernel-Build/releases/latest
[PRERELEASE]: https://github.com/okrc/WSL2-Kernel-Build/releases
[WSL2-Linux-Kernel REPO]: https://github.com/microsoft/WSL2-Linux-Kernel
[The-Linux-Kernel REPO]: https://www.kernel.org
