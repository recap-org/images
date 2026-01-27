FROM ubuntu:24.04
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
RUN curl -L https://github.com/recap-org/miktex/releases/download/25.12/miktex-25.12-linux-aarch64.tar.xz \
    -o /tmp/miktex.tar.xz \
    && cd /tmp \
    && tar -xf miktex.tar.xz \
    && cd /tmp/miktex-* \
    && ./install.sh \
    && rm -rf /tmp/miktex*
RUN https://github.com/WGUNDERWOOD/tex-fmt/releases/download/v0.5.6/tex-fmt-aarch64-linux.tar.gz \
    | tar -xz \
    && install -m 0755 tex-fmt /usr/local/bin/tex-fmt
RUN groupadd -g 1000 vscode && \
    useradd -m -u 1000 -g vscode vscode && \
    usermod -aG sudo vscode && \
    echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers;
USER vscode
RUN pipx install cookiecutter && \
    # Install Oh My Zsh and plugins
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" && \
    sed -i 's/plugins=(git)/plugins=(git)/g' ~/.zshrc

# Set working directory
WORKDIR /workspaces
# Set the default command
CMD ["/bin/zsh"]
