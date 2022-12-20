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
    openjdk-17-jdk-headless \
    maven \
    curl \
    gettext-base \
    && \
    rm -rf /var/lib/apt/lists/*


# copy tls-playground files

COPY . "/opt/tls-playground/"


# define interface

WORKDIR "/opt/tls-playground"

ENV TLS_PLAYGROUND_PASS="1234"

ENTRYPOINT ["/usr/bin/bash"]

VOLUME ["/opt/tls-playground"]

EXPOSE 80
EXPOSE 443

