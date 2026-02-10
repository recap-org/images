# syntax=docker/dockerfile:1.4

FROM core
ARG TARGETARCH
ARG R_VERSION
ARG QUARTO_VERSION
ARG RADIAN_VERSION
USER root
# Install Quarto, R and Pandoc
RUN curl -L https://rig.r-pkg.org/deb/rig.gpg -o /etc/apt/trusted.gpg.d/rig.gpg && \
    sh -c 'echo "deb http://rig.r-pkg.org/deb rig main" > /etc/apt/sources.list.d/rig.list' && \
    apt-get update && apt-get install -y r-rig pandoc --no-install-recommends && \
    curl -L https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-${TARGETARCH}.deb \
    -o /tmp/quarto.deb && \
    apt-get install -y /tmp/quarto.deb && \
    rm /tmp/quarto.deb && \
    apt-get purge -y --auto-remove && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/* && \
    find /usr/share/doc -depth -type f ! -name copyright -delete && \
    find /usr/share/doc -empty -delete && \
    rm -rf /usr/share/man/* /usr/share/info/*
# Install radian via pipx
RUN pipx install radian==${RADIAN_VERSION} && \
    rm -rf ${PIPX_HOME}/venvs/*/lib/*/site-packages/tests
# Create renv cache directory and give all rights to all users
RUN mkdir -p /renv/cache && \
    chmod -R a+rwX /renv
USER ubuntu
# Install specific R version and set as default
RUN rig add ${R_VERSION} && \
    rig default ${R_VERSION} && \
    R -e "install.packages(c('pak', 'renv', 'rmarkdown', 'languageserver'))" && \
    R -e "pak::pkg_install(c('ManuelHentschel/vscDebugger', 'nx10/unigd', 'nx10/httpgd'))" && \
    sudo apt-get purge -y --auto-remove && \
    sudo rm -rf /var/lib/apt/lists/* /var/cache/apt/* && \
    sudo find /usr/share/doc -depth -type f ! -name copyright -delete && \
    sudo find /usr/share/doc -empty -delete && \
    sudo rm -rf /usr/share/man/* /usr/share/info/*
# Set working directory
WORKDIR /workspaces
# Set the default command
CMD ["/bin/zsh"]
