#!/bin/bash

set -e

export HOME=/home/vps
export USER=vps
export DISPLAY=:1

echo "======================================"
echo "        VPS + VNC + noVNC"
echo "======================================"
echo "User: $USER"
echo "Display: $DISPLAY"
echo "Web port: 8080"
echo "======================================"

mkdir -p "$HOME/.vnc"

# Remove old VNC session if any
vncserver -kill :1 >/dev/null 2>&1 || true

rm -f "$HOME/.vnc"/*.pid
rm -f "$HOME/.vnc"/*.log

echo "[1/3] Starting VNC..."

vncserver :1 \
    -geometry 1024x768 \
    -depth 24 \
    -localhost no \
    -SecurityTypes None \
    --I-KNOW-THIS-IS-INSECURE

echo "[2/3] Waiting for VNC..."

sleep 3

if ! (netstat -tln 2>/dev/null | grep -q ":5901"); then
    echo "ERROR: VNC is not listening on 5901"
    cat "$HOME/.vnc/"*.log 2>/dev/null || true
    exit 1
fi

echo "VNC is running on port 5901"

echo "[3/3] Starting noVNC on port 8080..."

exec websockify \
    --web=/usr/share/novnc \
    0.0.0.0:8080 \
    127.0.0.1:5901
