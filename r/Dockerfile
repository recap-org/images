# syntax=docker/dockerfile:1.2

FROM recap-core:latest
ARG ARCH=arm64
ENV OARCH=${ARCH}
RUN case "$ARCH" in \
    arm64)  OARCH=aarch64 ;; \
    amd64)  OARCH=x86_64 ;; \
    *) echo "Unsupported ARCH: $ARCH" && exit 1 ;; \
    esac && \
    echo "OARCH=$OARCH" >> /etc/environment
ARG R_VERSION=4.5.2
ARG QUARTO_VERSION=1.8.27
USER root
RUN curl -L https://rig.r-pkg.org/deb/rig.gpg -o /etc/apt/trusted.gpg.d/rig.gpg && \
    sh -c 'echo "deb http://rig.r-pkg.org/deb rig main" > /etc/apt/sources.list.d/rig.list' && \
    apt-get update && apt-get install -y r-rig pandoc && \ 
    # Install Quarto
    curl -L https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-${ARCH}.deb \
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
    pipx install radian && \
    ln -s /home/ubuntu/.local/bin/radian /usr/local/bin/radian
# Set working directory
WORKDIR /workspaces
# Set the default command
CMD ["/bin/zsh"]
