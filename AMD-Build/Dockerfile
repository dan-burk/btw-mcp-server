# AMD64 Dockerfile for cross-platform builds from ARM64 hosts
#
# WHY AMD64?
# - Posit Package Manager provides precompiled x86_64 Linux binaries
# - No source compilation needed = MUCH faster builds
# - QEMU emulation during build is slow, but only happens once
# - The resulting image runs fast on any AMD64 host
#
# BUILD COMMAND (from the project root directory, NOT from AMD-Build):
#   docker buildx build --platform linux/amd64 -t btw-mcp-server:amd64 -f AMD-Build/Dockerfile --load .
#
# If buildx isn't set up yet:
#   docker buildx create --name mybuilder --use
#   docker buildx inspect --bootstrap

# Explicitly target AMD64 platform
FROM --platform=linux/amd64 rocker/r-ver:4.4.3

# Install Linux system build dependencies
# Even with binary packages, some dependencies may need compilation
RUN apt-get update && apt-get install -y \
    build-essential \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    libgit2-dev \
    libsodium-dev \
    libmagick++-dev \
    cmake \
    git \
 && rm -rf /var/lib/apt/lists/*

# Configure Posit Package Manager for precompiled Ubuntu 22.04 (jammy) x86_64 binaries
# This is the key optimization - binary packages, no compilation!
RUN echo 'options(repos = c(CRAN = "https://packagemanager.posit.co/cran/__linux__/jammy/latest"))' >> /usr/local/lib/R/etc/Rprofile.site

# Install btw package - should download precompiled binary from Posit Package Manager
# Falls back to r-universe if btw isn't on CRAN/PPM
RUN R -e "options(warn = 2); install.packages('btw', repos = c('https://packagemanager.posit.co/cran/__linux__/jammy/latest', 'https://posit-dev.r-universe.dev', 'https://cloud.r-project.org'), dependencies = TRUE)"

# Verify btw installed
RUN R -e "packageVersion('btw')"

# Install ellmer package (needed for custom run_r_code tool)
RUN R -e "options(warn = 2); install.packages('ellmer', repos = c('https://packagemanager.posit.co/cran/__linux__/jammy/latest', 'https://posit-dev.r-universe.dev', 'https://cloud.r-project.org'), dependencies = TRUE)"

# Verify ellmer installed
RUN R -e "packageVersion('ellmer')"

# Create app directory
WORKDIR /app

# Copy the MCP server script (build context is project root)
COPY r-mcp-server.r /app/r-mcp-server.r

# Set entrypoint for MCP server
ENTRYPOINT ["Rscript", "/app/r-mcp-server.r"]
