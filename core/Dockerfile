# syntax=docker/dockerfile:1.2

ARG UBUNTU_VERSION
FROM ubuntu:${UBUNTU_VERSION}
ARG TARGETARCH
ARG MIKTEX_VERSION
ARG TEX_FMT_VERSION
ARG COOKIECUTTER_VERSION

ENV MIKTEX_ROOT=/usr/local/miktex \
    PATH=/usr/local/miktex/bin:$PATH \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    PIPX_HOME=/usr/local/pipx \
    PIPX_BIN_DIR=/usr/local/bin
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash ca-certificates git curl wget perl locales sudo \
    build-essential python3 python3-pip python3-venv pipx \
    \
    # Required libraries for MiKTeX
    fontconfig \
    libpopt0 libexpat1 liburiparser1 libmspack0 \
    liblog4cxx15 libpng16-16 libgraphite2-3 \
    libzzip-0-13 libcairo2 libmpfr6 \
    libicu-dev libboost-locale-dev \
    \
    # utils
    gnupg2 dirmngr zsh \
    iproute2 procps lsof psmisc \
    rsync unzip zip xz-utils bzip2 \
    less jq tree htop nano dialog \
    lsb-release bash-completion \
    openssh-client \
    \
    && apt-get purge -y --auto-remove \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/* /tmp/* /var/tmp/*  \
    && find /usr/share/doc -depth -type f ! -name copyright -delete \
    && find /usr/share/doc -empty -delete \
    && rm -rf /usr/share/man/* /usr/share/info/*
RUN sed -i '/$LANG/s/^# //g' /etc/locale.gen && \
    locale-gen $LANG && \
    update-locale LANG=$LANG && \
    find /usr/share/locale -mindepth 1 -maxdepth 1 ! -name 'en_US*' -exec rm -rf {} + && \
    rm -rf /usr/share/i18n
COPY ./core/install.sh /tmp/miktex-install.sh
RUN curl -L https://github.com/recap-org/miktex/releases/download/${MIKTEX_VERSION}/miktex-${MIKTEX_VERSION}-linux-$(uname -m).tar.xz \
    -o /tmp/miktex.tar.xz \
    && cd /tmp && tar -xf miktex.tar.xz \
    && /tmp/miktex-install.sh --from /tmp/miktex*/miktex \
    && rm -rf /tmp/miktex* /tmp/*.sh
RUN curl -L https://github.com/WGUNDERWOOD/tex-fmt/releases/download/v${TEX_FMT_VERSION}/tex-fmt-$(uname -m)-linux.tar.gz \
    | tar -xz \
    && install -m 0755 tex-fmt /usr/local/bin/tex-fmt \
    && rm -f tex-fmt
RUN echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    chsh -s $(which zsh)
RUN pipx install cookiecutter==${COOKIECUTTER_VERSION} && \
    rm -rf ${PIPX_HOME}/venvs/*/lib/*/site-packages/tests
USER ubuntu
# Install Oh My Zsh and plugins
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    sed -i 's/plugins=(git)/plugins=(git)/g' ~/.zshrc && \
    # check for updates of miktex packages (remove outdated packages message)
    miktex packages update-package-database && \
    miktex packages update
# Set working directory
WORKDIR /workspaces
# Set the default command
CMD ["/bin/zsh"]
