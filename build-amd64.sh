#!/bin/bash
# =============================================================================
# Build Antigravity Tools Docker Image for AMD64
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Building Antigravity Tools Docker Image (amd64)..."
echo "Using --no-cache to ensure latest version is fetched..."
docker build \
    --no-cache \
    --build-arg TARGETARCH=amd64 \
    -t antigravity-tools:amd64 \
    -t antigravity-tools:latest \
    .

echo ""
echo "✅ Build complete!"
echo "   Image: antigravity-tools:amd64"
echo ""
echo "Run with: docker run -d -p 6080:6080 -p 8045:8045 antigravity-tools:amd64"
