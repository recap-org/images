#!/bin/bash
set -euo pipefail

if [ -f /features/quarto ]; then
  echo "Quarto feature is already installed. Skipping installation."
  exit 0
fi

RECAP_USER="${RECAP_USER:-ubuntu}"

if [ "$(id -u)" -eq 0 ]; then
  echo "Error: this script must be run as the non-root user '$RECAP_USER' (not as root)." >&2
  echo "Tip: remove 'USER root' from your Dockerfile before running this script." >&2
  exit 1
fi

ARCH=$(dpkg --print-architecture)
sudo apt-get update && sudo apt-get install -y pandoc --no-install-recommends
sudo curl -L https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-${ARCH}.deb \
    -o /tmp/quarto.deb
sudo apt-get install -y /tmp/quarto.deb
sudo rm /tmp/quarto.deb
sudo apt-get purge -y --auto-remove
sudo rm -rf /var/lib/apt/lists/* /var/cache/apt/*
sudo find /usr/share/doc -depth -type f ! -name copyright -delete
sudo find /usr/share/doc -empty -delete
sudo rm -rf /usr/share/man/* /usr/share/info/*

sudo mkdir -p /features
sudo touch /features/quarto
