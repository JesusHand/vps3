#!/bin/bash

set -e

export HOME=/home/vps
export USER=vps
export DISPLAY=:1
export XDG_RUNTIME_DIR=/run/user/1000

VNC_PORT="${VNC_PORT:-5901}"
NOVNC_PORT="${NOVNC_PORT:-8080}"
RESOLUTION="${RESOLUTION:-1280x720}"

echo "========================================"
echo "        Ubuntu VPS + noVNC"
echo "========================================"
echo "User       : $USER"
echo "Display    : $DISPLAY"
echo "VNC Port   : $VNC_PORT"
echo "Web Port   : $NOVNC_PORT"
echo "Resolution : $RESOLUTION"
echo "========================================"

mkdir -p "$HOME/.vnc"
mkdir -p "$XDG_RUNTIME_DIR"

chmod 700 "$HOME/.vnc"
chmod 700 "$XDG_RUNTIME_DIR"

# ----------------------------------------
# Stop old display if exists
# ----------------------------------------
vncserver -kill "$DISPLAY" >/dev/null 2>&1 || true

# ----------------------------------------
# Start TigerVNC
# ----------------------------------------
echo "[+] Starting VNC..."

vncserver "$DISPLAY" \
    -geometry "$RESOLUTION" \
    -depth 24 \
    -localhost no

# ----------------------------------------
# Find actual VNC display port
# ----------------------------------------
VNC_DISPLAY_PORT=$((5900 + ${DISPLAY#:}))

echo "[+] VNC running on port $VNC_DISPLAY_PORT"

# ----------------------------------------
# Start noVNC
# ----------------------------------------
echo "[+] Starting noVNC..."

exec websockify \
    --web=/usr/share/novnc \
    "0.0.0.0:${NOVNC_PORT}" \
    "127.0.0.1:${VNC_DISPLAY_PORT}"
