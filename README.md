# rffmpeg Worker

Docker container for distributed FFmpeg transcoding with [rffmpeg](https://github.com/joshuaboniface/rffmpeg).

## Overview

This container provides an SSH-accessible FFmpeg worker for use with Jellyfin's rffmpeg distributed transcoding setup. Workers receive FFmpeg commands over SSH and execute them locally, allowing transcoding workloads to be distributed across multiple machines.

## Features

- Based on Ubuntu 24.04
- Includes `jellyfin-ffmpeg7` with hardware acceleration support
- SSH server for remote command execution
- Multi-architecture support (amd64, arm64)

## Usage

### Docker Compose

```yaml
services:
  rffmpeg-worker:
    image: ghcr.io/dionjones615/rffmpeg-worker:latest
    volumes:
      - /path/to/authorized_keys:/etc/authorized_keys/authorized_keys:ro
      - /path/to/media:/data:ro
      - /path/to/transcodes:/data/transcodes
    ports:
      - "2222:22"
```

### Kubernetes

See the Terraform configuration in the homelab repository for Kubernetes StatefulSet deployment.

### Environment Variables

- `SSH_AUTHORIZED_KEY`: SSH public key to authorize (alternative to volume mount)

## Building

```bash
docker build -t rffmpeg-worker .
```

## License

MIT
