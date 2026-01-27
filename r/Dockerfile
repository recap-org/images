# syntax=docker/dockerfile:1.2

ARG RECAP_VERSION
FROM ghcr.io/recap-org/recap-core:${RECAP_VERSION}
ARG TARGETARCH
ARG R_VERSION
ARG QUARTO_VERSION
ARG RADIAN_VERSION
USER root
RUN curl -L https://rig.r-pkg.org/deb/rig.gpg -o /etc/apt/trusted.gpg.d/rig.gpg && \
    sh -c 'echo "deb http://rig.r-pkg.org/deb rig main" > /etc/apt/sources.list.d/rig.list' && \
    apt-get update && apt-get install -y r-rig pandoc && \ 
    # Install Quarto
    curl -L https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-${TARGETARCH}.deb \
    -o /tmp/quarto.deb && \
    apt-get install -y /tmp/quarto.deb && \
    rm /tmp/quarto.deb && \
    # create directory for Renv cache and set permissions
    mkdir -p /renv/cache && \
    chown -R ubuntu:ubuntu /renv && \
    chmod -R 755 /renv && \
    # Clean up apt cache
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
USER ubuntu
# Install specific R version and set as default
RUN rig add ${R_VERSION} && \
    rig default ${R_VERSION} && \
    R -e "pak::pkg_install(c('renv', 'rmarkdown', 'languageserver', 'ManuelHentschel/vscDebugger', 'nx10/httpgd', 'tidyverse'))" && \
    pipx install radian==${RADIAN_VERSION} && \
    ln -s /home/ubuntu/.local/bin/radian /usr/local/bin/radian
# Set working directory
WORKDIR /workspaces
# Set the default command
CMD ["/bin/zsh"]
