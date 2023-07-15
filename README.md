```

     ,-~~~-.
    (  <O>  )`~-,.___..,--~~~-,-..___.,--~\
    |`~---~'|   :      :      :       :    \
    |       |   :   TLS Playground    :   <
    |       |   :      :      :       :   /
     `~---~' `~-'.___..'--~~~-'-..___.'--~'

```



# TLS Playground Project

This TLS Playground (TP) demonstrates various TLS scenarios, including certificate handling and client/server interactions over TLS.



## TP Components

The TP consist of several loosely related components.
These can all be controlled with the **[TP CLI Tool](bin/README.md)**.

### Certificate Utilities

Utilities for dealing with [CSRs and certificates](cert/README.md) using openssl.

### Demo CAs

Configuration samples and utilities for running [Certificate Authorities (CA)](ca/README.md) based on `openssl ca`.

### ACME Utilities

Configuation samples and utilities for obtaining certificates through the [ACME](acme/README.md) protocol using Certbot.

### Demo Servers

Demo [(web) servers](server/README.md) using various configurations and certificates.

### Demo Clients

Demo [clients](client/README.md) using various configurations and certificates.



## Using TP Locally

TODO list pre-requisites

TODO limitations: need internet facing host with public DNS record


## Using TP with Docker

### Building a TP Docker Image

Use the following to create a Docker image of the TLS Playground and all its prerequisites:

```
$ docker image pull debian:testing-slim
$ docker build --tag "${DOCKER_HUB_USER}/tls-playground:latest" .
$ docker image push "${DOCKER_HUB_USER}/tls-playground:latest" .
```

### Running with Docker

TODO

#### Env-Vars

TODO

#### Volume Mounts

TODO

### Developing with Docker

TODO
