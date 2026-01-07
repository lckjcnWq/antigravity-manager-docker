#!/bin/bash
# =============================================================================
# Build Antigravity Tools Docker Image for Both Architectures
# Requires Docker Buildx for multi-platform builds
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

IMAGE_NAME="${IMAGE_NAME:-antigravity-tools}"
PUSH="${PUSH:-false}"

echo "Building Antigravity Tools Docker Image (multi-arch)..."
echo "  Platforms: linux/amd64, linux/arm64"
echo ""

# Create builder if not exists
docker buildx create --name multiarch --use 2>/dev/null || docker buildx use multiarch

BUILD_CMD="docker buildx build --platform linux/amd64,linux/arm64"

if [ "$PUSH" = "true" ]; then
    echo "Push enabled. Building and pushing..."
    BUILD_CMD="$BUILD_CMD --push"
else
    echo "Push disabled. Building locally (use PUSH=true to push)..."
    BUILD_CMD="$BUILD_CMD --load"
fi

$BUILD_CMD -t "$IMAGE_NAME:latest" .

echo ""
echo "✅ Build complete!"
echo ""
echo "To push to Docker Hub:"
echo "  PUSH=true IMAGE_NAME=username/antigravity-tools ./build-multiarch.sh"
