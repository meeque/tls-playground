```

     ,-~~~-.
    (  <O>  )`~-,.___..,--~~~-,-..___.,--~\
    |`~---~'|   :      :      :       :    \
    |       |   :   TLS Playground    :   <
    |       |   :      :      :       :   /
     `~---~' `~-'.___..'--~~~-'-..___.'--~'

```



# TLS Playground Project

This TLS Playground demonstrates various TLS scenarios, including certificate handling and client/server interactions over TLS.



## TP Components

### Certificate Utilities

Utilities for dealing with CSRs and certificates using openssl.

### Private Certificate Authorities

Configuration samples and utilities for running [Certificate Authorities (CA)](ca/) based on `openssl ca`.

### ACME / Let's Encypt

Configuation samples and utilities for obtaining certificates through the ACME protocol using Certbot.

### Servers

Sample [web servers](server/) using various TLS certificate configurations.

### Clients

[Generic client support](client-generic/) for using TLS client certificates with web browsers or `curl`.

A simple [TLS-enabled HTTP client in Java](client-java/) supporting different TLS setups, including client certificates.



## Using TP with Docker

### Building with Docker

Use the following to create a Docker image of the TLS Playground and all its prerequisites:

```
$ docker image pull debian:testing-slim
$ docker build --tag user/tls-playground:latest .
$ docker image push user/tls-playground:latest .
```

### Running with Docker

TODO

#### Env-Vars

TODO

#### Volume Mounts

TODO

