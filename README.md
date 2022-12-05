# TLS Playground Project

This playground demonstrates various TLS scenarios, including certificate handling and client server interactions over TLS.



## Components

### Certificate Authority

Wrapper scripts and configuration samples for running an (incomplete) [Certificate Authority (CA)](ca/) based on `openssl ca`.

### Server: nginx

A sample [nginx server](server-nginx/) using various TLS certificate configurations in distinct virtual hosts.

### Client: Generic

[Generic client support](client-generic/) for using TLS client certificates with web browsers or `curl`.

### Client: Java

A simple [TLS-enabled HTTP client in Java](client-java/) supporting different TLS setups, including client certificates.



## Building and Running with Docker

Use the following to create a Docker image of the TLS playground and all its prerequisites:

```
$ docker image pull debian:testing-slim
$ docker build --tag user/tls-playground:latest .
$ docker image push user/tls-playground:latest .
```

