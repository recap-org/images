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

# install R
wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc \
  | sudo gpg --dearmor -o /usr/share/keyrings/cran.gpg

echo "deb [signed-by=/usr/share/keyrings/cran.gpg] \
    https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" \
    | sudo tee /etc/apt/sources.list.d/cran.list > /dev/null
sudo apt-get update

R_FULL=$(apt-cache madison r-base \
  | awk '{print $3}' \
  | grep -E "^${R_VERSION}(-|$)" \
  | sort -Vr \
  | head -n1)

if [ -z "$R_FULL" ]; then
  echo "Error: R ${R_VERSION} not found in repository"
  exit 1
fi

echo "Installing R version: $R_FULL"

sudo apt-get -y install --no-install-recommends \
    r-base=${R_FULL} \
    r-base-html=${R_FULL} \
    r-base-dev=${R_FULL} \
    r-doc-html=${R_FULL}

sudo apt-get purge -y --auto-remove 
sudo rm -rf /var/lib/apt/lists/* /var/cache/apt/* 
sudo find /usr/share/doc -depth -type f ! -name copyright -delete 
sudo find /usr/share/doc -empty -delete 
sudo rm -rf /usr/share/man/* /usr/share/info/*

sudo mkdir -p /usr/local/lib/R/site-library
sudo chown -R ${RECAP_USER:-ubuntu} /usr/local/lib/R/site-library

# Install R packages
cat >> ~/.Rprofile <<'EOF'
options(
  repos = c(
    CRAN = sprintf(
      "https://packagemanager.posit.co/cran/latest/bin/linux/noble-%s/%s",
      R.version["arch"],
      substr(getRversion(), 1, 3)
    )
  )
)
EOF
Rscript -e "install.packages(c('pak', 'renv', 'rmarkdown', 'languageserver'))"
Rscript -e "pak::pkg_install(c('ManuelHentschel/vscDebugger', 'nx10/unigd', 'nx10/httpgd'))"

# Install radian via pipx
sudo pipx install radian==${RADIAN_VERSION}
sudo rm -rf ${PIPX_HOME}/venvs/*/lib/*/site-packages/tests
sudo mkdir -p /renv/cache
sudo chmod -R a+rwX /renv

sudo mkdir -p /features
sudo touch /features/R