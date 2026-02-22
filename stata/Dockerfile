FROM ghcr.io/recap-org/core:latest
USER root
COPY --from=dataeditors/stata19_5-mp-x:2026-02-18 /usr/local/stata /usr/local/stata
ENV PATH="/usr/local/stata:${PATH}"
COPY stata.lic /usr/local/stata/stata.lic
RUN sudo apt-get update && apt-get install -y --no-install-recommends \
    libncurses6
RUN curl https://xpra.org/get-xpra.sh | bash
USER ubuntu
