#!/bin/bash
set -euo pipefail

if [ -f /features/R ]; then
  echo "R feature is already installed. Skipping installation."
  exit 0
fi

RECAP_USER="${RECAP_USER:-ubuntu}"

if [ "$(id -u)" -eq 0 ]; then
  echo "Error: this script must be run as the non-root user '$RECAP_USER' (not as root)." >&2
  echo "Tip: remove 'USER root' from your Dockerfile before running this script." >&2
  exit 1
fi

ARCH=$(dpkg --print-architecture)

# Install rig (sets up CRAN + PPM, installs pak with sysreqs, configures user libraries)
sudo curl -fsSL https://rig.r-pkg.org/deb/rig.gpg -o /etc/apt/trusted.gpg.d/rig.gpg
echo "deb http://rig.r-pkg.org/deb rig main" | sudo tee /etc/apt/sources.list.d/rig.list > /dev/null
sudo apt-get update
sudo apt-get -y install --no-install-recommends r-rig

# Install R
sudo rig add ${R_VERSION}

sudo apt-get purge -y --auto-remove
sudo rm -rf /var/lib/apt/lists/* /var/cache/apt/*
sudo find /usr/share/doc -depth -type f ! -name copyright -delete
sudo find /usr/share/doc -empty -delete
sudo rm -rf /usr/share/man/* /usr/share/info/*

# Install R packages (pak preinstalled by rig)
Rscript -e "pak::pkg_install(c('renv', 'rmarkdown', 'languageserver', 'httpgd', 'ManuelHentschel/vscDebugger'))"

# Install radian via uv
uv tool install radian==${RADIAN_VERSION}

# Install rv (R dependency manager)
curl -fsSL "https://github.com/A2-ai/rv/releases/download/v${RV_VERSION}/rv-v${RV_VERSION}-$([ "$ARCH" = "arm64" ] && echo aarch64 || echo x86_64)-unknown-linux-gnu.tar.gz" \
    | sudo tar -xz -C /usr/local/bin

sudo mkdir -p /renv/cache
sudo chmod -R a+rwX /renv

sudo mkdir -p /features
sudo touch /features/R
