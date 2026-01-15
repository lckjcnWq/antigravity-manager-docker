#!/bin/bash
# =============================================================================
# Build Antigravity Tools Docker Image with Specific Version
# Usage: ./build-version.sh <version> [arch]
# Examples:
#   ./build-version.sh 1.2.3          # Build version 1.2.3 for arm64
#   ./build-version.sh 1.2.3 amd64    # Build version 1.2.3 for amd64
#   ./build-version.sh 1.2.3 arm64    # Build version 1.2.3 for arm64
# =============================================================================

set -e

# Check arguments
if [ -z "$1" ]; then
    echo "❌ Error: Version is required"
    echo ""
    echo "Usage: $0 <version> [arch]"
    echo ""
    echo "Examples:"
    echo "  $0 1.2.3          # Build version 1.2.3 for arm64 (default)"
    echo "  $0 1.2.3 amd64    # Build version 1.2.3 for amd64"
    echo ""
    echo "To list available versions, run:"
    echo "  curl -s https://api.github.com/repos/lbjlaq/Antigravity-Manager/releases | jq -r '.[].tag_name'"
    exit 1
fi

VERSION="$1"
ARCH="${2:-arm64}"

# Validate architecture
if [ "$ARCH" != "amd64" ] && [ "$ARCH" != "arm64" ]; then
    echo "❌ Error: Invalid architecture '$ARCH'"
    echo "   Supported: amd64, arm64"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "========================================="
echo "  Building Antigravity Tools Docker"
echo "  Version: v${VERSION}"
echo "  Architecture: ${ARCH}"
echo "========================================="
echo ""

# Verify version exists on GitHub
echo "Checking if version v${VERSION} exists..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "https://api.github.com/repos/lbjlaq/Antigravity-Manager/releases/tags/v${VERSION}")
if [ "$HTTP_CODE" != "200" ]; then
    echo "❌ Error: Version v${VERSION} not found on GitHub"
    echo ""
    echo "Available versions:"
    curl -s https://api.github.com/repos/lbjlaq/Antigravity-Manager/releases | jq -r '.[].tag_name' | head -10
    exit 1
fi
echo "✅ Version v${VERSION} found"
echo ""

echo "Building Docker image..."
docker build \
    --no-cache \
    --build-arg TARGETARCH="$ARCH" \
    --build-arg VERSION="$VERSION" \
    -t "antigravity-tools:v${VERSION}" \
    -t "antigravity-tools:v${VERSION}-${ARCH}" \
    .

echo ""
echo "✅ Build complete!"
echo "   Image tags:"
echo "     - antigravity-tools:v${VERSION}"
echo "     - antigravity-tools:v${VERSION}-${ARCH}"
echo ""
echo "Run with:"
echo "  docker run -d -p 6080:6080 -p 8045:8045 antigravity-tools:v${VERSION}"
