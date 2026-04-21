#!/bin/bash
set -euo pipefail

if [ -f /features/nbstata ]; then
  echo "nbstata feature is already installed. Skipping installation."
  exit 0
fi

RECAP_USER="${RECAP_USER:-ubuntu}"

if [ "$(id -u)" -eq 0 ]; then
  echo "Error: this script must be run as the non-root user '$RECAP_USER' (not as root)." >&2
  echo "Tip: remove 'USER root' from your Dockerfile before running this script." >&2
  exit 1
fi

if [ ! -f /features/jupyter ]; then
  echo "Error: Jupyter must be installed first. Run install_jupyter.sh before this script." >&2
  exit 1
fi

# Install nbstata into the Jupyter venv
uv pip install --python /opt/jupyter/bin/python nbstata

# Register the nbstata kernel (--user so VS Code can discover it)
/opt/jupyter/bin/python -m nbstata.install --user

sudo mkdir -p /features
sudo touch /features/nbstata
