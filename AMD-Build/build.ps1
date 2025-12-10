# Build AMD64 Docker image from ARM64 host using buildx
#
# Run this script from the project root directory:
#   .\AMD-Build\build.ps1

$ErrorActionPreference = "Stop"

# Check if buildx is available
try {
    docker buildx version | Out-Null
} catch {
    Write-Host "Error: docker buildx is not available" -ForegroundColor Red
    Write-Host "Please install Docker Desktop or enable buildx manually"
    exit 1
}

# Create builder if it doesn't exist
$builderExists = docker buildx inspect amd64builder 2>$null
if (-not $builderExists) {
    Write-Host "Creating buildx builder 'amd64builder'..." -ForegroundColor Yellow
    docker buildx create --name amd64builder --use
    docker buildx inspect --bootstrap
} else {
    Write-Host "Using existing buildx builder 'amd64builder'" -ForegroundColor Green
    docker buildx use amd64builder
}

# Build the AMD64 image
Write-Host ""
Write-Host "Building AMD64 image (this may take a while due to QEMU emulation)..." -ForegroundColor Cyan
Write-Host "But packages should be precompiled binaries from Posit Package Manager!" -ForegroundColor Cyan
Write-Host ""

docker buildx build `
    --platform linux/amd64 `
    -t btw-mcp-server:amd64 `
    -f AMD-Build/Dockerfile `
    --load `
    .

Write-Host ""
Write-Host "Build complete! Image tagged as btw-mcp-server:amd64" -ForegroundColor Green
Write-Host ""
Write-Host "To run:"
Write-Host "  docker run --rm btw-mcp-server:amd64"
