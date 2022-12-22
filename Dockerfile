FROM debian:testing-slim


# install prerequisites

RUN apt-get update \
    && \
    apt-get upgrade --assume-yes \
    && \
    apt-get install --assume-yes --option 'APT::Install-Recommends=false' \
    ca-certificates \
    openssl \
    certbot \
    nginx \
    curl \
    gettext-base \
    coreutils \
    lsof \
    procps \
    psmisc \
    && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && \
    apt-get upgrade --assume-yes \
    && \
    apt-get install --assume-yes --option 'APT::Install-Recommends=false' \
    openjdk-17-jdk-headless \
    maven \
    && \
    rm -rf /var/lib/apt/lists/*


# copy tls-playground files

COPY . "/opt/tls-playground/"


# define interface

WORKDIR "/opt/tls-playground"

# TODO remove TLS_PLAYGROUND_PASS once fully replaced by TP_PASS
ENV TLS_PLAYGROUND_PASS="1234"
ENV TP_PASS="1234"
ENV TP_SERVER_DOMAIN="localhost"
ENV TP_SERVER_LISTEN_ADDRESS="127.0.0.1"
ENV TP_SERVER_HTTP_PORT=8080
ENV TP_SERVER_HTTPS_PORT=8443

ENTRYPOINT ["/usr/bin/bash"]

VOLUME ["/opt/tls-playground"]

EXPOSE 80
EXPOSE 443

