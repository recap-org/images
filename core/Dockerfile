# syntax=docker/dockerfile:1.2

FROM ubuntu:24.04
ARG ARCH=arm64
ENV OARCH=${ARCH}
RUN case "$ARCH" in \
    arm64)  OARCH=aarch64 ;; \
    amd64)  OARCH=x86_64 ;; \
    *) echo "Unsupported ARCH: $ARCH" && exit 1 ;; \
    esac && \
    echo "OARCH=$OARCH" >> /etc/environment
ARG MIKTEX_VERSION=25.12
ARG TEX_FMT_VERSION=0.5.6
ENV MIKTEX_ROOT=/usr/local/miktex \
    PATH=/usr/local/miktex/bin:$PATH \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash ca-certificates git curl wget perl locales sudo \
    python3 python3-pip python3-venv pipx \
    \
    # dev toolchain
    build-essential \
    libssl-dev libcurl4-openssl-dev libxml2-dev zlib1g-dev \
    libglpk-dev \
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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN sed -i '/$LANG/s/^# //g' /etc/locale.gen && \
    locale-gen $LANG && \
    update-locale LANG=$LANG
RUN curl -L https://github.com/recap-org/miktex/releases/download/${MIKTEX_VERSION}/miktex-${MIKTEX_VERSION}-linux-${OARCH}.tar.xz \
    -o /tmp/miktex.tar.xz \
    && cd /tmp \
    && tar -xf miktex.tar.xz \
    && cd /tmp/miktex-* \
    && ./install.sh \
    && rm -rf /tmp/miktex*
RUN curl -L https://github.com/WGUNDERWOOD/tex-fmt/releases/download/v${TEX_FMT_VERSION}/tex-fmt-${OARCH}-linux.tar.gz \
    | tar -xz \
    && install -m 0755 tex-fmt /usr/local/bin/tex-fmt
RUN echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN chsh -s $(which zsh)
USER ubuntu
RUN pipx install cookiecutter && \
    # Install Oh My Zsh and plugins
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    sed -i 's/plugins=(git)/plugins=(git)/g' ~/.zshrc && \
    # check for updates of miktex packages (remove outdated packages message)
    miktex packages update-package-database && \
    miktex packages update

# Set working directory
WORKDIR /workspaces
# Set the default command
CMD ["/bin/zsh"]
