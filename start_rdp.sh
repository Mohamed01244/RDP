#!/bin/bash
docker rm -f fast-rdp || true
docker run -d \
  --name=fast-rdp \
  -p 3000:3000 \
  -v "$(pwd):/config" \
  -e TZ=Africa/Cairo \
  --shm-size="2gb" \
  --restart unless-stopped \
  ghcr.io/linuxserver/webtop:ubuntu-xfce
