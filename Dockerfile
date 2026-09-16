FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/home/vps

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    xfce4 \
    xfce4-terminal \
    dbus-x11 \
    novnc \
    websockify \
    x11vnc \
    xvfb \
    supervisor \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -u 1000 -s /bin/bash vps

RUN mkdir -p /home/vps/.config /tmp/runtime-vps && \
    chown -R 1000:1000 /home/vps /tmp/runtime-vps

COPY start.sh /start.sh

RUN chmod +x /start.sh && \
    chown 1000:1000 /start.sh

ENV DISPLAY=:99
ENV PORT=8080

EXPOSE 8080

USER 1000:1000

WORKDIR /home/vps

CMD ["/start.sh"]
