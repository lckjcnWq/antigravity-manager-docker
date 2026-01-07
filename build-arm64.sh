#!/bin/bash
# =============================================================================
# Build Antigravity Tools Docker Image for ARM64
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "Building Antigravity Tools Docker Image (arm64)..."
docker build \
    --build-arg TARGETARCH=arm64 \
    -t antigravity-tools:arm64 \
    -t antigravity-tools:latest \
    .

echo ""
echo "✅ Build complete!"
echo "   Image: antigravity-tools:arm64"
echo ""
echo "Run with: docker run -d -p 6080:6080 -p 8045:8045 antigravity-tools:arm64"
