# =============================================================================
# Antigravity Tools Docker Container (Optimized)
# Provides Web VNC access to the Tauri desktop application
# Automatically fetches latest version from GitHub
# =============================================================================

FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Shanghai

# Display configuration
ENV DISPLAY=:99
ENV RESOLUTION=1280x720x24

# Target architecture: amd64 or aarch64
ARG TARGETARCH=amd64

# =============================================================================
# Install dependencies in single layer with aggressive cleanup
# =============================================================================
RUN apt-get update && apt-get install -y --no-install-recommends \
    # X11 and display (minimal)
    xvfb \
    x11vnc \
    # Lightweight window manager
    openbox \
    # noVNC for web access
    novnc \
    websockify \
    # GTK and WebKit dependencies (required by Tauri) - minimal set
    libgtk-3-0t64 \
    libwebkit2gtk-4.1-0 \
    # Additional Tauri dependencies
    libayatana-appindicator3-1 \
    librsvg2-common \
    # Graphics dependencies for ARM64/headless rendering
    libgbm1 \
    libegl1 \
    libgl1-mesa-dri \
    # Utilities (minimal)
    wget \
    curl \
    ca-certificates \
    dbus-x11 \
    libfuse2 \
    jq \
    # Process management
    supervisor \
    # Fonts - use lighter alternative (only ~5MB vs 100MB+ for noto-cjk)
    fonts-wqy-microhei \
    # Clean up aggressively
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /usr/share/doc/* \
    && rm -rf /usr/share/man/* \
    && rm -rf /usr/share/locale/* \
    && rm -rf /var/cache/apt/*

# =============================================================================
# Download Antigravity Tools AppImage from GitHub
# Supports: latest version (default) or specific version via VERSION arg
# =============================================================================

# Optional: specify version to build (e.g., "1.2.3"), empty = latest
ARG VERSION=""

RUN set -ex && \
    mkdir -p /opt/antigravity && \
    # Map Docker TARGETARCH to AppImage arch naming
    case "${TARGETARCH}" in \
    "arm64") APPIMAGE_ARCH="aarch64" ;; \
    "amd64"|*) APPIMAGE_ARCH="amd64" ;; \
    esac && \
    echo "=== Target architecture: ${TARGETARCH} -> ${APPIMAGE_ARCH} ===" && \
    # Fetch release info from GitHub API (specific version or latest)
    if [ -n "${VERSION}" ]; then \
        echo "=== Fetching specific version: v${VERSION} ===" && \
        RELEASE_INFO=$(curl -sS "https://api.github.com/repos/lbjlaq/Antigravity-Manager/releases/tags/v${VERSION}"); \
        ACTUAL_VERSION="${VERSION}"; \
    else \
        echo "=== Fetching latest release from GitHub... ===" && \
        RELEASE_INFO=$(curl -sS "https://api.github.com/repos/lbjlaq/Antigravity-Manager/releases/latest"); \
        ACTUAL_VERSION=$(echo "$RELEASE_INFO" | jq -r '.tag_name' | sed 's/^v//'); \
    fi && \
    echo "=== Version: ${ACTUAL_VERSION} ===" && \
    # Save version for labels
    echo "${ACTUAL_VERSION}" > /opt/antigravity/VERSION && \
    # Extract AppImage URL directly using grep (more reliable than complex jq)
    echo "=== Searching for ${APPIMAGE_ARCH} AppImage... ===" && \
    DOWNLOAD_URL=$(echo "$RELEASE_INFO" | grep -o "https://[^\"]*${APPIMAGE_ARCH}\.AppImage" | head -1) && \
    echo "=== Found URL: ${DOWNLOAD_URL} ===" && \
    if [ -z "$DOWNLOAD_URL" ]; then \
    echo "ERROR: Could not find AppImage for ${APPIMAGE_ARCH}" && \
    echo "Available assets:" && \
    echo "$RELEASE_INFO" | jq -r '.assets[].name' && \
    exit 1; \
    fi && \
    # Download AppImage with progress
    echo "=== Downloading AppImage... ===" && \
    wget --progress=dot:giga "${DOWNLOAD_URL}" -O /opt/antigravity/antigravity.AppImage && \
    # Verify download
    FILESIZE=$(stat -c%s /opt/antigravity/antigravity.AppImage) && \
    echo "=== Downloaded file size: ${FILESIZE} bytes ===" && \
    if [ "$FILESIZE" -lt 1000000 ]; then \
    echo "ERROR: Downloaded file is too small" && \
    exit 1; \
    fi && \
    chmod +x /opt/antigravity/antigravity.AppImage && \
    # Extract AppImage
    echo "=== Extracting AppImage... ===" && \
    cd /opt/antigravity && \
    ./antigravity.AppImage --appimage-extract && \
    rm antigravity.AppImage && \
    mv squashfs-root app && \
    # Verify
    if [ ! -f /opt/antigravity/app/AppRun ]; then \
    echo "ERROR: AppRun not found" && \
    ls -la /opt/antigravity/ && \
    exit 1; \
    fi && \
    echo "=== Success! ===" && \
    ls -la /opt/antigravity/app/AppRun && \
    rm -rf app/usr/share/doc app/usr/share/man 2>/dev/null || true

WORKDIR /opt/antigravity

# =============================================================================
# Configuration files
# =============================================================================
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY start.sh /start.sh
RUN chmod +x /start.sh && mkdir -p /root/.antigravity_tools

# Labels
LABEL org.opencontainers.image.source="https://github.com/lbjlaq/Antigravity-Manager"

# =============================================================================
# Expose ports
# =============================================================================
EXPOSE 6080 8045

# =============================================================================
# Volume for persistent data
# =============================================================================
VOLUME ["/root/.antigravity_tools"]

# =============================================================================
# Health check
# =============================================================================
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD curl -sf http://localhost:6080/ || exit 1

# =============================================================================
# Start
# =============================================================================
CMD ["/start.sh"]
