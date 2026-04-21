#!/bin/bash
set -euo pipefail

if [ -f /features/claude-code ]; then
  echo "Claude Code feature is already installed. Skipping installation."
  exit 0
fi

RECAP_USER="${RECAP_USER:-ubuntu}"

if [ "$(id -u)" -eq 0 ]; then
  echo "Error: this script must be run as the non-root user '$RECAP_USER' (not as root)." >&2
  echo "Tip: remove 'USER root' from your Dockerfile before running this script." >&2
  exit 1
fi

# Install Claude Code via native installer
curl -fsSL https://claude.ai/install.sh | bash

sudo mkdir -p /features
sudo touch /features/claude-code
