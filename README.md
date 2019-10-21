# TLS Playground Project

This playground demonstrates various TLS scenarios, including certificate handling and client server interactions over TLS.



## Components

### Certificate Authority

Wrapper scripts and configuration samples for running an (incomplete) [Certificate Authority (CA)](ca/) based on `openssl ca`.

### Server: nginx

A sample [nginx server](nginx/) using various TLS certificate configurations in distinct virtual hosts.

### Client: Java

A simple [TLS-enabled HTTP client in Java](client-java/) supporting different TLS setups, including client certificates.
