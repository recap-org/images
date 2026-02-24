# syntax=docker/dockerfile:1.4

FROM core
USER root
COPY --from=dataeditors/stata19_5-mp-x:2026-02-18 /usr/local/stata /usr/local/stata
ENV PATH="/usr/local/stata:${PATH}"
RUN apt-get update && apt-get install -y --no-install-recommends \
    libncurses6
RUN wget -O "/usr/share/keyrings/xpra.asc" https://xpra.org/xpra.asc && \
    wget -O "/etc/apt/sources.list.d/xpra.sources" https://raw.githubusercontent.com/Xpra-org/xpra/master/packaging/repos/noble/xpra.sources && \
    apt-get update && apt-get install -y --no-install-recommends \
    libgtk2.0-0 \
    xpra-html5 \
    xpra-x11 \
    xpra-server \
    openbox \
    obconf \
    xauth && \
    apt-get purge -y --auto-remove && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/*
ENV XDG_RUNTIME_DIR=/tmp/runtime-ubuntu
RUN mkdir -p /tmp/runtime-ubuntu && \
    chown ubuntu:ubuntu /tmp/runtime-ubuntu && \
    chmod 700 /tmp/runtime-ubuntu
COPY ./stata/scripts/* /usr/local/bin/
RUN chmod +x /usr/local/bin/stata-gui /usr/local/bin/install-stata-license
USER ubuntu
# Set working directory
WORKDIR /workspaces
# Set the default command
CMD ["/bin/zsh"]
