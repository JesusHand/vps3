FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/home/vps
ENV USER=vps
ENV DISPLAY=:1
ENV VNC_PORT=5901
ENV NOVNC_PORT=8080
ENV RESOLUTION=1024x768

# Install desktop + VNC + noVNC
RUN apt-get update && apt-get install -y --no-install-recommends \
    xfce4 \
    xfce4-terminal \
    dbus-x11 \
    tightvncserver \
    novnc \
    websockify \
    ca-certificates \
    procps \
    net-tools \
    curl \
    wget \
    bash \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user with UID 1000
RUN groupadd -g 1000 vps && \
    useradd -m -u 1000 -g 1000 -s /bin/bash vps

# VNC directories
RUN mkdir -p /home/vps/.vnc && \
    chown -R 1000:1000 /home/vps

# XFCE startup
RUN printf '%s\n' \
    '#!/bin/sh' \
    'unset SESSION_MANAGER' \
    'unset DBUS_SESSION_BUS_ADDRESS' \
    'export DISPLAY=:1' \
    'exec startxfce4' \
    > /home/vps/.vnc/xstartup && \
    chmod +x /home/vps/.vnc/xstartup && \
    chown 1000:1000 /home/vps/.vnc/xstartup

# Startup script
COPY start.sh /start.sh

RUN chmod +x /start.sh && \
    chown 1000:1000 /start.sh

# Blitz web port
EXPOSE 8080

# Blitz-compatible user
USER 1000:1000

WORKDIR /home/vps

ENTRYPOINT ["/start.sh"]
