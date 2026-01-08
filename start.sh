#!/bin/bash
# =============================================================================
# Antigravity Tools Container Startup Script
# =============================================================================

set -e

echo "========================================="
echo "  Antigravity Tools Docker Container"
echo "========================================="

# Show version info
if [ -f /opt/antigravity/VERSION ]; then
    echo "  Version: $(cat /opt/antigravity/VERSION)"
fi
echo "========================================="

# Create X11 socket directory
mkdir -p /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix

# Create XDG runtime directory (required by some GTK apps)
mkdir -p /tmp/runtime-root
chmod 700 /tmp/runtime-root
export XDG_RUNTIME_DIR=/tmp/runtime-root

# Initialize D-Bus (required by GTK applications)
if [ ! -d /run/dbus ]; then
    mkdir -p /run/dbus
fi
dbus-daemon --system --fork 2>/dev/null || true

# Set resolution from environment variable
RESOLUTION=${RESOLUTION:-1280x720x24}
echo "Display resolution: ${RESOLUTION}"

# Create supervisor log directory
mkdir -p /var/log/supervisor

# Start supervisor (manages Xvfb, x11vnc, noVNC, and application)
echo "Starting services via supervisor..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
