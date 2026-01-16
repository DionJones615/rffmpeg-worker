#!/bin/bash
set -e

# Copy authorized_keys if mounted
if [ -f /etc/authorized_keys/authorized_keys ]; then
    mkdir -p /root/.ssh
    cp /etc/authorized_keys/authorized_keys /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    chmod 700 /root/.ssh
    echo "Authorized keys configured from /etc/authorized_keys"
fi

# If authorized_keys provided via SSH_AUTHORIZED_KEY env var
if [ -n "$SSH_AUTHORIZED_KEY" ]; then
    mkdir -p /root/.ssh
    echo "$SSH_AUTHORIZED_KEY" >> /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys
    chmod 700 /root/.ssh
    echo "Authorized key added from environment"
fi

# Verify ffmpeg is accessible
echo "FFmpeg version:"
ffmpeg -version | head -1

echo "FFprobe version:"
ffprobe -version | head -1

echo "Starting SSH server..."
exec "$@"
