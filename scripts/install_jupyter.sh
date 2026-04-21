#!/bin/bash
set -euo pipefail

if [ -f /features/jupyter ]; then
  echo "Jupyter feature is already installed. Skipping installation."
  exit 0
fi

RECAP_USER="${RECAP_USER:-ubuntu}"

if [ "$(id -u)" -eq 0 ]; then
  echo "Error: this script must be run as the non-root user '$RECAP_USER' (not as root)." >&2
  echo "Tip: remove 'USER root' from your Dockerfile before running this script." >&2
  exit 1
fi

# Create a dedicated venv for Jupyter at /opt/jupyter
sudo mkdir -p /opt/jupyter
sudo chown $(whoami) /opt/jupyter
uv venv /opt/jupyter
uv pip install --python /opt/jupyter/bin/python jupyterlab

# Symlink jupyter to PATH
sudo ln -sf /opt/jupyter/bin/jupyter /usr/local/bin/jupyter

# Remove the default kernel that points to the Jupyter venv's Python
rm -rf /opt/jupyter/share/jupyter/kernels/python3

# Register the uv-managed Python as the default Jupyter kernel
~/.local/bin/pip install ipykernel
~/.local/bin/python -m ipykernel install --user --name python3 --display-name "Python 3"

sudo mkdir -p /features
sudo touch /features/jupyter
