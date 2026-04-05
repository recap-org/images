# syntax=docker/dockerfile:1.4

ARG UBUNTU_VERSION
FROM ubuntu:${UBUNTU_VERSION}
ARG TARGETARCH
ARG MIKTEX_VERSION
ARG TEX_FMT_VERSION
ARG COOKIECUTTER_VERSION
ARG R_VERSION
ARG QUARTO_VERSION
ARG RADIAN_VERSION
ARG STATA_VERSION

ENV MIKTEX_ROOT=/usr/local/miktex \
    PATH=/usr/local/miktex/bin:$PATH \
    MIKTEX_VERSION=${MIKTEX_VERSION} \
    TEX_FMT_VERSION=${TEX_FMT_VERSION} \
    COOKIECUTTER_VERSION=${COOKIECUTTER_VERSION} \
    R_VERSION=${R_VERSION} \
    QUARTO_VERSION=${QUARTO_VERSION} \
    RADIAN_VERSION=${RADIAN_VERSION} \
    STATA_VERSION=${STATA_VERSION} \
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
RUN curl -L https://github.com/WGUNDERWOOD/tex-fmt/releases/download/v${TEX_FMT_VERSION}/tex-fmt-$(uname -m)-linux.tar.gz \
    | tar -xz \
    && install -m 0755 tex-fmt /usr/local/bin/tex-fmt \
    && rm -f tex-fmt
RUN echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    chsh -s $(which zsh)
RUN pipx install cookiecutter==${COOKIECUTTER_VERSION} && \
    rm -rf ${PIPX_HOME}/venvs/*/lib/*/site-packages/tests
COPY ./scripts /scripts
RUN chmod +x /scripts/*
USER ubuntu
# Install Oh My Zsh and plugins
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    sed -i 's/plugins=(git)/plugins=(git)/g' ~/.zshrc
# Install MiKTeX
RUN curl -fsSL https://raw.githubusercontent.com/recap-org/miktex/dev/install.sh \
    | bash -s -- --version ${MIKTEX_VERSION}
# Set working directory
WORKDIR /workspaces
# Set the default command
CMD ["/bin/zsh"]
