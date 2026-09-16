FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1
ENV HOME=/home/vps
ENV USER=vps
ENV VNC_PORT=5901
ENV NOVNC_PORT=8080
ENV RESOLUTION=1280x720

# -----------------------------
# System packages
# -----------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    xfce4 \
    xfce4-terminal \
    dbus-x11 \
    x11-xserver-utils \
    xterm \
    tigervnc-standalone-server \
    tigervnc-tools \
    novnc \
    websockify \
    supervisor \
    sudo \
    curl \
    wget \
    git \
    nano \
    vim \
    unzip \
    zip \
    ca-certificates \
    net-tools \
    iproute2 \
    procps \
    htop \
    python3 \
    python3-pip \
    firefox \
    fonts-liberation \
    fonts-noto \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------
# Create non-root user
# UID 1000 is required by Blitz
# -----------------------------
RUN useradd \
    --uid 1000 \
    --gid 1000 \
    --create-home \
    --home-dir /home/vps \
    --shell /bin/bash \
    vps \
    && echo "vps ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vps \
    && chmod 0440 /etc/sudoers.d/vps

# -----------------------------
# VNC directories
# -----------------------------
RUN mkdir -p \
    /home/vps/.vnc \
    /home/vps/.config \
    /run/user/1000 \
    /opt/startup \
    && chown -R 1000:1000 /home/vps /run/user/1000

# -----------------------------
# VNC startup configuration
# -----------------------------
RUN printf '%s\n' \
    '#!/bin/sh' \
    'unset SESSION_MANAGER' \
    'unset DBUS_SESSION_BUS_ADDRESS' \
    'export DISPLAY=:1' \
    'exec startxfce4' \
    > /home/vps/.vnc/xstartup \
    && chmod +x /home/vps/.vnc/xstartup \
    && chown 1000:1000 /home/vps/.vnc/xstartup

# -----------------------------
# Startup script
# -----------------------------
COPY start.sh /opt/startup/start.sh

RUN chmod +x /opt/startup/start.sh \
    && chown 1000:1000 /opt/startup/start.sh

# -----------------------------
# Blitz detects this port
# -----------------------------
EXPOSE 8080

# -----------------------------
# Run as Blitz-compatible user
# -----------------------------
USER 1000:1000

WORKDIR /home/vps

ENTRYPOINT ["/opt/startup/start.sh"]
