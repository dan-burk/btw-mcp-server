#!/bin/bash
# Build AMD64 Docker image from ARM64 host using buildx
#
# Run this script from the project root directory:
#   ./AMD-Build/build.sh

set -e

# Check if buildx is available
if ! docker buildx version > /dev/null 2>&1; then
    echo "Error: docker buildx is not available"
    echo "Please install Docker Desktop or enable buildx manually"
    exit 1
fi

# Create builder if it doesn't exist
if ! docker buildx inspect amd64builder > /dev/null 2>&1; then
    echo "Creating buildx builder 'amd64builder'..."
    docker buildx create --name amd64builder --use
    docker buildx inspect --bootstrap
else
    echo "Using existing buildx builder 'amd64builder'"
    docker buildx use amd64builder
fi

# Build the AMD64 image
echo ""
echo "Building AMD64 image (this may take a while due to QEMU emulation)..."
echo "But packages should be precompiled binaries from Posit Package Manager!"
echo ""

docker buildx build \
    --platform linux/amd64 \
    -t btw-mcp-server:amd64 \
    -f AMD-Build/Dockerfile \
    --load \
    .

echo ""
echo "Build complete! Image tagged as btw-mcp-server:amd64"
echo ""
echo "To run:"
echo "  docker run --rm btw-mcp-server:amd64"
