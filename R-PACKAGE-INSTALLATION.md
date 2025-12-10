# R Package Installation on ARM64 Windows

A compatibility guide for installing R packages across different environments when running on ARM64 Windows hardware.

## The Problem

ARM64 Windows is a challenging platform for R development because:
- Pre-built binaries are only available for x86_64 Windows and macOS
- Native ARM64 R requires compiling everything from source
- Docker adds another layer of complexity with architecture emulation

## Compatibility Matrix

| Environment | R Version | Repository | Binaries Available | Install Function | Status |
|-------------|-----------|------------|-------------------|------------------|--------|
| **ARM64 Windows (Emulated x86_64 R)** |||||
| | R 4.4.3 x86_64 | CRAN | `.zip` (x86_64) | `install.packages()` | ✅ Works |
| | R 4.4.3 x86_64 | GitHub | `.tar.gz` only | `remotes::install_github()` | ❌ Must compile from source (might work with emulated Rtools44 x86_64, untested) |
| | R 4.4.3 x86_64 | Posit r-universe | `.zip` (x86_64) | `install.packages(..., repos='https://posit-dev.r-universe.dev')` | ✅ Works |
| **ARM64 Windows (Native Aarch64 R)** | Requires [Rtools44-aarch64](https://cran.r-project.org/bin/windows/Rtools/) ||||
| | R 4.4.3 Aarch64 | CRAN | `.tar.gz` only | `install.packages()` | ✅ Works, compiles from source (⚠️ slower) |
| | R 4.4.3 Aarch64 | GitHub | `.tar.gz` only | `remotes::install_github()` | ✅ Works, compiles from source (⚠️ slower) |
| | R 4.4.3 Aarch64 | Posit r-universe | `.tar.gz` only | `install.packages(..., repos='https://posit-dev.r-universe.dev')` | ✅ Works, compiles from source (⚠️ slower) |
| **Docker ARM64 Image (Native)** | See [Appendix A](#appendix-a-arm64-docker-base-images) for base image options ||||
| | rocker/r-ver:4.4.3 | CRAN | `.tar.gz` only | `install.packages()` | ⚠️ Compiles from source (very slow) |
| | rocker/r-ver:4.4.3 | GitHub | `.tar.gz` only | `remotes::install_github()` | ⚠️ Compiles from source (very slow) |
| | rocker/r-ver:4.4.3 | Posit r-universe | `.tar.gz` only | `install.packages(..., repos='https://posit-dev.r-universe.dev')` | ⚠️ Compiles from source (very slow) |
| **Docker AMD64 Image (QEMU Emulated)** |||||
| | rocker/r-ver:4.4.3 | CRAN | `.tar.gz` only | `install.packages()` | ❌ TERRIBLY SLOW & UNSTABLE |
| | rocker/r-ver:4.4.3 | GitHub | `.tar.gz` only | `remotes::install_github()` | ❌ TERRIBLY SLOW & UNSTABLE |
| | rocker/r-ver:4.4.3 | Posit r-universe | `.tar.gz` only | `install.packages(..., repos='https://posit-dev.r-universe.dev')` | ❌ TERRIBLY SLOW & UNSTABLE |
| | rocker/r-ver:4.4.3 | Posit Package Manager | Linux precompiled / `.tar.gz` | `install.packages(...,`<br>`repos='https://packagemanager.pos`<br>`it.co/cran/__linux__/jammy/latest')` | ⚠️ TERRIBLY SLOW (Untested) |

## Legend

| Symbol | Meaning |
|--------|---------|
| ✅ | Works well, uses pre-built binaries (`.zip` on Windows, `.tgz` on macOS) |
| ⚠️ | Must compile from `.tar.gz` source package (long build times) |
| ❌ | Does not work or impractically slow |

## Recommendations

### Best Option: Docker ARM64 (Native)
Use native ARM64 Docker images and accept the one-time compilation cost during image build. Once built, the image is reusable on ARM64 hosts (note: the vast majority of Linux servers are x86_64, not ARM64).

```dockerfile
FROM rocker/r-ver:4.4.3  # Multi-arch, uses ARM64 natively
RUN R -e "install.packages('btw', repos = c('https://posit-dev.r-universe.dev', 'https://cloud.r-project.org'))"
```

### Avoid: Docker AMD64 on ARM64
Running x86_64 Docker images via QEMU emulation on ARM64 hardware is extremely slow and not recommended.

## Notes

- Rtools is required for source compilation on Windows
- Linux compilation requires `build-essential` and various `-dev` packages
- r-universe (posit-dev) sometimes has newer package versions than CRAN

## Posit Public Package Manager (Linux Binaries)

Unlike CRAN/r-universe, [Posit Public Package Manager](https://packagemanager.posit.co/) provides **precompiled Linux binaries** for common distros (Ubuntu, Debian, RHEL, etc.). This can dramatically speed up Docker builds.

Example for Ubuntu (x86_64 only currently):
```r
options(repos = c(CRAN = "https://packagemanager.posit.co/cran/__linux__/jammy/latest"))
install.packages("btw")  # Downloads precompiled binary, no compilation!
```

**Caveat**: Posit Package Manager only has x86_64 Linux binaries, not ARM64. So this doesn't help ARM64 Docker builds.

---

## Appendix A: ARM64 Docker Base Images

### Official Rocker Images

| Image | ARM64 Support | Notes |
|-------|---------------|-------|
| [rocker/r-ver](https://hub.docker.com/r/rocker/r-ver) | ✅ R 4.1.0+ (experimental) | Multi-arch, uses ARM64 natively. **Our choice.** |
| [rocker/r-base](https://hub.docker.com/r/rocker/r-base) | ✅ Full multi-arch | amd64, arm64v8, ppc64le, s390x |
| rocker/rstudio | ❌ Limited | RStudio Server has no ARM64 binaries |
| rocker/shiny | ❌ Limited | Shiny Server has no official ARM64 binaries |
| rocker/tidyverse | ⚠️ Experimental | Depends on rocker/rstudio |

**Why limited Shiny/RStudio ARM64?** The Rocker team can't easily build these because RStudio Server and Shiny Server don't distribute ARM64 binaries—building from source requires compiling boost, pandoc, etc.

### Community ARM64 Shiny Images

If you need Shiny Server on ARM64, these community projects build it from source:

| Image | Features |
|-------|----------|
| [hvalev/shiny-server-arm](https://github.com/hvalev/shiny-server-arm-docker) | Builds Shiny Server from source for ARM64/armv7. ~2hr build time. |
| [shiny-server-arm-python](https://github.com/sravanpannala/shiny-server-arm-python) | Fork with Python + R support |

### References

- [Rocker Project Images](https://rocker-project.org/images/)
- [rocker-org/rocker-versioned2](https://github.com/rocker-org/rocker-versioned2)
- [Shiny Server ARM64 Issue #458](https://github.com/rstudio/shiny-server/issues/458)

---

## Appendix B: ARM64 Windows Compiler Requirements

Different languages have different compiler requirements on ARM64 Windows:

| Language | Compiler Toolchain | Self-contained? |
|----------|-------------------|-----------------|
| **R** | Rtools44-aarch64 (LLVM 17/clang) | ✅ Yes |
| **Python** | Visual Studio Build Tools (MSVC) | ❌ No |

**Key takeaway:** Rtools44-aarch64 bundles its own LLVM compiler. Unlike Python on ARM64 Windows, R does NOT require Visual Studio Build Tools to compile packages from source.
