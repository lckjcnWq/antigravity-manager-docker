#!/bin/bash
# =============================================================================
# Antigravity Tools Container Startup Script
# =============================================================================

set -e

echo "========================================="
echo "  Antigravity Tools Docker Container"
echo "========================================="

# Create X11 socket directory
mkdir -p /tmp/.X11-unix
chmod 1777 /tmp/.X11-unix

# Initialize D-Bus (required by GTK applications)
if [ ! -d /run/dbus ]; then
    mkdir -p /run/dbus
fi
dbus-daemon --system --fork 2>/dev/null || true

# Set resolution from environment variable
RESOLUTION=${RESOLUTION:-1280x720x24}
echo "Display resolution: ${RESOLUTION}"

# Start supervisor (manages Xvfb, x11vnc, noVNC, and application)
echo "Starting services via supervisor..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
