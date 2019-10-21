# TLS Playground Generic Client Support

This TLS Playground component helps you with using client certificates. This is particularly useful when accessing [TLS Playground nginx server2](../server-nginx/).



## Client Certificates Usage

### Obtaining Client Certs

The [TLS Playground nginx server2](../server-nginx/) expects client certificates to be signed by [TLS Playground ca2](../ca/). The TLS Generic Client Support does not come with hard-coded certificates, but it contains sample configurations. After you have bootstrapped `ca2`, you can obtain appropriate certificates by running the following `ca.sh` command in the root directory of the TLS Playground:

    ca/ca.sh request ca2 client-generic/tls/client1.config
    ca/ca.sh request ca2 client-generic/tls/client2.config

This generate appropriate private keys and certificates in the `client-generic/tls` directory.



### Using Client Certs with curl

Then you can use the new certificate with CLI clients like `curl`. For example, to issue a request with a valid client certificate to TLS Playground nginx `server2`, issue the following command:

    curl --cacert ca/ca1/ca-cert.pem --cert client-generic/tls/client1-cert.pem --key client-generic/tls/private/client1-key.pem --pass 1234 https://server2.tls-playground.localhost:8443/

This request should yield a status 200 response. Without providing a client certificate, you would receive an status 400 error response instead.



### Importing Client Certs into a Browser

