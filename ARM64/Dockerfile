# ARM64 Dockerfile
#
# BUILD COMMAND (from project root):
#   docker build -t btw-mcp-server:arm64 -f ARM64/Dockerfile .

FROM --platform=linux/arm64 rocker/r-ver:4.4.3

# Install Linux system build dependencies for R packages
# This is the Linux equivalent of Rtools on Windows
# Compiles .tar.gz source packages into .so shared libraries
#
# Dependency               | Purpose
# -------------------------|----------------------------------
# build-essential          | gcc, g++, make (core build tools)
# libcurl4-openssl-dev     | HTTP requests (curl/httr)
# libssl-dev               | SSL/TLS encryption (openssl)
# libxml2-dev              | XML parsing (xml2)
# libfontconfig1-dev       | System font discovery (textshaping)
# libharfbuzz-dev          | Text shaping engine (textshaping)
# libfribidi-dev           | Bidirectional text (textshaping)
# libfreetype6-dev         | Font rendering (ragg/systemfonts)
# libpng-dev               | PNG image support (png)
# libtiff5-dev             | TIFF image support (tiff)
# libjpeg-dev              | JPEG image support (jpeg)
# libgit2-dev              | Git operations (gert/git2r)
# libsodium-dev            | Cryptography (sodium/credentials)
# libmagick++-dev          | ImageMagick C++ (magick)
# cmake                    | Build system for some packages
# git                      | Git CLI for package installs
#
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

# Install btw package from r-universe
RUN R -e "options(warn = 2); install.packages('btw', repos = c('https://posit-dev.r-universe.dev', 'https://cloud.r-project.org'), dependencies = TRUE)"

# Verify btw installed
RUN R -e "packageVersion('btw')"

# Install ellmer package
RUN R -e "options(warn = 2); install.packages('ellmer', repos = c('https://posit-dev.r-universe.dev', 'https://cloud.r-project.org'), dependencies = TRUE)"

# Verify ellmer installed
RUN R -e "packageVersion('ellmer')"

# Create app directory
WORKDIR /app

# Install additional R packages from packages.r
COPY packages.r /tmp/packages.r
RUN Rscript /tmp/packages.r

# Copy the MCP server script
COPY r-mcp-server.r /app/r-mcp-server.r

# Set entrypoint for MCP server
ENTRYPOINT ["Rscript", "/app/r-mcp-server.r"]
