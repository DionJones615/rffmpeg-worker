# rffmpeg Worker Container
# Provides FFmpeg transcoding over SSH for distributed Jellyfin transcoding
#
# Based on Ubuntu with jellyfin-ffmpeg for hardware acceleration support

FROM ubuntu:24.04

ARG TARGETPLATFORM
ARG DEBIAN_FRONTEND=noninteractive

ENV NVIDIA_DRIVER_CAPABILITIES="compute,video,utility"

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    gnupg2 \
    openssh-server \
    && rm -rf /var/lib/apt/lists/*

# Add Jellyfin repository and install jellyfin-ffmpeg
RUN case "${TARGETPLATFORM}" in \
        'linux/amd64') export ARCH='amd64' ;; \
        'linux/arm64') export ARCH='arm64' ;; \
        *) export ARCH='amd64' ;; \
    esac && \
    curl -fsSL https://repo.jellyfin.org/jellyfin_team.gpg.key | gpg --dearmor -o /usr/share/keyrings/jellyfin.gpg && \
    echo "deb [arch=${ARCH} signed-by=/usr/share/keyrings/jellyfin.gpg] https://repo.jellyfin.org/ubuntu noble main" > /etc/apt/sources.list.d/jellyfin.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends jellyfin-ffmpeg7 && \
    rm -rf /var/lib/apt/lists/*

# Create symlinks for ffmpeg/ffprobe in standard PATH
RUN ln -sf /usr/lib/jellyfin-ffmpeg/ffmpeg /usr/local/bin/ffmpeg && \
    ln -sf /usr/lib/jellyfin-ffmpeg/ffprobe /usr/local/bin/ffprobe

# Configure SSH
RUN mkdir -p /run/sshd /root/.ssh /etc/authorized_keys && \
    chmod 700 /root/.ssh /etc/authorized_keys && \
    # Allow root login with key only
    sed -i 's/#PermitRootLogin.*/PermitRootLogin prohibit-password/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    # Allow authorized_keys from /etc/authorized_keys
    echo "AuthorizedKeysFile .ssh/authorized_keys /etc/authorized_keys/%u" >> /etc/ssh/sshd_config && \
    # Generate host keys
    ssh-keygen -A

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D", "-e"]

LABEL org.opencontainers.image.source="https://github.com/DionJones615/rffmpeg-worker"
LABEL org.opencontainers.image.description="rffmpeg worker for distributed Jellyfin transcoding"
LABEL org.opencontainers.image.licenses="MIT"
