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

In order for web browsers to use a client certificate, they need to have both the certificate file and the corresponding private key. Unfortunately, most browsers and operating systems are picky when importing these. They need a to use a file format that can carry both the certificate and the private key in one file. Typically, they support the PKCS12 format.

Here is how you use `ca.sh` to bundle a certificate and corresponding key into a PKCS12 file. Run this command from the root directory of the TLS playground:

    ca/ca.sh pkcs12 client-generic/tls/client1-cert.pem

This command will assume a corresponding private key relative to the `client1-cert.pem`. In the above example, it will look for the private key in `client-generic/tls/private/client1-key.pem`. That is just where the previous `ca.sh request` sub-command has put the private key.

Likewise, the resulting PKCS12 file will be emitted to a path relative to `client1-cert.pem`. In the above example, it will be emitted to `client-generic/tls/private/client1.pfx`. The file will be encrypted with a passphrase specified in the `$TP_PASS` environment variable. As always this defaults to `1234`.

You can now install the certificate and key in your operating system, where most browsers will pick it up. For Firefox, you can instead install it in the browser itself. Follow these steps:

1. Open the Firefox *Certificate Manager* by going to *Preferences* >> *Privacy & Security* >> *View Certificates...*
2. Go to the *Your Certificates* tab, and click on *Import...*
3. Now select the client certificate PKCS12 file, e.g. `client1.pfx`.
4. When prompted for a passphrase enter `1234`.

