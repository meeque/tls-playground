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

Use the following to create a Docker image with the TLS Playground and all its prerequisites.
And upload it to [Docker Hub](https://hub.docker.com/), assuming your Docker Hub user account name is stored in environment variable `${DOCKER_HUB_USER}`.
Just execute these three commands:

```
docker image pull debian:testing-slim
docker build --tag "${DOCKER_HUB_USER}/tls-playground:latest" .
docker image push "${DOCKER_HUB_USER}/tls-playground:latest" .
```

You may also find a pre-built TLS PLayground image at [meeque/tls-playground:latest](https://hub.docker.com/r/meeque/tls-playground), but no guarantees that it's actually based on the latest sources.

### Running with Docker

The TP Docker image does **not** follow best practices for minimal containers and dedicated containers per application.
Since it is meant for easy exploration and learning rather than for productive use, TP bundles all functionality into a single Docker image.
Users are expected to run a shell inside the container and execute TP CLI commands manually.

For example, when using a [TP Demo Server](server/README.md) together with the [TP ACME Utilities](acme/README.md), both the ACME challenges server and the demo server will run inside the same container side-by-side.
And so will short-lived *OpenSSL* and *Certbot* commands.

Moreover, the TP Docker container will accumulate application state, such as private keys and certificates.
Therefore, it is preferable to create the container once and reuse it for all TLS Playground exploration.
You can do so with the following command:

```
docker container create --name 'tls-playground' --env 'TP_SERVER_DOMAIN=tls-playground.example' --env 'TP_SERVER_LISTEN_ADDRESS=*' --env 'TP_ACME_SERVER_URL=lets-encrypt-staging' --publish '0.0.0.0:80:8080' --publish '0.0.0.0:443:8443' "${DOCKER_HUB_USER}/tls-playground:latest" -c 'sleep infinity'
```

Though you may want to replace `tls-playground.example` in the above with your own domain name.
Or omit the `TP_SERVER_DOMAIN` env-var altogether, if you do not want to use TP with an ACME CA.
See the [TP CLI](bin/README.md) documentation for other supported environment variables.

Once you have configured the TP Docker container, you can start it with this command:

```
docker container start tls-playground
```

As mentioned above, the container won't do much after you've started it.
It will just sit there and wait.
You can than run a shell in the TP Docker container and start using the [TP CLI](bin/README.md) interactively using the built-in bash shell:

```
sudo docker container exec --tty --interactive tls-playground bash
```

By default, the shell inside the container displays `[TP]` in the prompt.
Once you `exit` the shell in the TP Docker container, you should fall back to your regular shell outside the container.

However, the container will keep running, including an TP demo servers that you've started in the container.
Once you do not need the TLS Playground anymore, you can stop the TP Docker container with the following command:

```
docker container stop tls-playground
```

#### Volume Mounts

TODO

### Developing with Docker

TODO
