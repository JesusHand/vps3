#!/bin/bash

set -e

export HOME=/home/vps
export USER=vps
export DISPLAY=:99
export XDG_RUNTIME_DIR=/tmp/runtime-vps

echo "Starting Xvfb..."

Xvfb :99 \
    -screen 0 1024x768x24 \
    -ac \
    +extension GLX \
    +render \
    -noreset &

sleep 2

echo "Starting XFCE..."

dbus-launch --exit-with-session startxfce4 &

sleep 5

echo "Starting x11vnc..."

x11vnc \
    -display :99 \
    -rfbport 5900 \
    -localhost \
    -nopw \
    -forever \
    -shared \
    -noxdamage &

sleep 2

echo "Starting noVNC on port 8080..."

exec websockify \
    --web=/usr/share/novnc \
    0.0.0.0:8080 \
    127.0.0.1:5900
