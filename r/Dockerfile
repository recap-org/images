# syntax=docker/dockerfile:1.4

FROM core
ARG TARGETARCH
USER root
COPY ./scripts /scripts
RUN chmod +x /scripts/*
USER ubuntu
RUN /scripts/install_R.sh
RUN /scripts/install_quarto.sh
