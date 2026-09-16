FROM --platform=linux/amd64 ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install desktop + VNC + noVNC
RUN apt-get update && apt-get install --no-install-recommends -y \
    xfce4 \
    xfce4-goodies \
    tigervnc-standalone-server \
    novnc \
    websockify \
    xterm \
    dbus-x11 \
    x11-utils \
    x11-xserver-utils \
    x11-apps \
    sudo \
    vim \
    net-tools \
    curl \
    wget \
    git \
    tzdata \
    openssl \
    firefox \
    xubuntu-icon-theme \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user required by blitz.cloud
RUN useradd -m -s /bin/bash vncuser \
    && echo "vncuser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/vncuser \
    && chmod 0440 /etc/sudoers.d/vncuser

# Prepare XFCE/VNC directories
RUN mkdir -p /home/vncuser/.vnc \
    && chown -R vncuser:vncuser /home/vncuser

# XFCE startup
RUN printf '%s\n' \
    '#!/bin/sh' \
    'unset SESSION_MANAGER' \
    'unset DBUS_SESSION_BUS_ADDRESS' \
    'startxfce4 &' \
    > /home/vncuser/.vnc/xstartup \
    && chmod +x /home/vncuser/.vnc/xstartup \
    && chown vncuser:vncuser /home/vncuser/.vnc/xstartup

# Blitz will expose the web interface through HTTPS
EXPOSE 8080

# Run everything as non-root user
USER vncuser

WORKDIR /home/vncuser

# Start VNC on 5901 and noVNC/websockify on 8080
CMD ["bash", "-c", "mkdir -p /home/vncuser/.vnc && vncserver -localhost no -SecurityTypes None -geometry 1024x768 :1 && websockify --web=/usr/share/novnc/ 8080 localhost:5901 && tail -f /dev/null"]
