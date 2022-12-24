# TLS Playground Certificate Authority (CA)

This TLS Playground component implements opinionated, easy to use, but incomplete Certificate Authorities (CAs). It is based on `openssl ca` and other `openssl` commands.

These CAs are not intended for production use, or even for use in a public facing test scenario. It lacks important CA features, like domain ownership verification and certificate revocation. Also, it uses a default passphrase to protect certificate keys.



## CA Usage

You can control the provided CAs by running the wrapper script `ca.sh`. The following exmples assume that you run `ca.sh` from the root directory of the TLS Playground Project, i.e. the parent of this directory.

The CAs use PEM as their standard file format. Wherever keys, certificate signing requests (CSRs), and certificates are involved they will be PEM encoded. For private keys, passphrase encryption is used, based on the value of environment variable `$TP_PASS`. If not specified in the environment, the passphrase defaults to `1234`.



### Bootstrapping/Resetting a CA

This TLS Playground component comes with two [preconfigured CAs](ca.conf), `ca1` and `ca2`. Each ca uses its own self-signed root certificate. These root certificates are not hard-coded, but can be genereted according to their respective CSR configuration. Find here the CSR configurations for [ca1](ca1/ca-req.config) and [ca2](ca2/ca-req.config) respectively.

Use the `ca.sh` sub-command `reset` to bootstrap or reset one of the preconfigured CAs. This will generate a new root certificate and create some house-keeping files that are necessary for CA operations.

Run the following commands to bootstrap both CAs:

    ca/ca.sh reset ca1
    ca/ca.sh reset ca2

After that, you will find new files in the respective CA's base directory. This includes `ca-csr.pem`, `ca-cert.pem`, `private/ca-key.pem`, `db.txt`, and `serial`.

When you rerun the `reset` sub-command on an existing CA, all previously stored CA data will be lost.



### Issuing Certs based on CSRs

Once a CA is bootstrapped, you can use it issue and sign new certificates. If you have already created a CSR for your certificate, you use the `ca.sh` sub-command `sign`. For instance, to issue a new certificate with `ca1`, issue the following command:

    ca/ca.sh sign ca1 path/to/my-csr.pem path/to/my-new-cert-link.pem

Here, the `my-csr.pem` argument represents the PEM-encoded CSR file that you have generated. The optional `my-new-cert-link.pem` argument represents the location where a symlink to the newly signed certificate will be created.

In any case, `ca.sh` will emit the new certificate in the `newcerts` subdirectory of the CA that you use. The name of the new certificate will be `SERIAL.pem`, where `SERIAL` is a unique serial number issued by the respective CA.



### Issuing Certs based on Configuration

The `ca.sh` script also supports the convenience sub-command `request`. This sub-command will perform two steps:

1. Create a new key-pair and CSR, based on an `openssl` CSR configuration file.
(This step is typically the requester's responsibility, not a CA responsibility.)
2. Issue and sign a new certificate based on that CSR.

For example, the following command will use `ca1` to create and sign a new request based on a config file:

    ca/ca.sh request ca1 path/to/my.config

This `request` command will do the following:

1. Create a new private key and CSR file next to the `my.config` file.
These will go to `private/my-key.pem` and `my-csr.pem` respectively.
2. Use `ca1` to issue and sign a new certificate. 
The certificate will be symlinked to `my-cert.pem`, located next to the `my.config` file.

If any of the above-mentioned files already exist, they will by overwritten.



## Useful OpenSSL Commands

When you deal with CSRs and certificates, you can also use `openssl` directly. Here is some useful `openssl` commands for introspecting such files.



### Introspecting CSRs

To display CSR contents in text form:

    openssl req -in client-generic/tls/client1-csr.pem -noout -text

To verify a CSR:

    openssl req -in client-generic/tls/client1-csr.pem -noout -verify



### Introspecting Certificates

To display certificate contents in text form:

    openssl x509 -in path/to/foo-cert.pem -noout -text

To print certificate fingerprints using various hash functions:

    openssl x509 -in path/to/foo-cert.pem -noout -fingerprint -md5
    openssl x509 -in path/to/foo-cert.pem -noout -fingerprint -sha1
    openssl x509 -in path/to/foo-cert.pem -noout -fingerprint -sha256

To verify a certificate against a custom CA certificate:

    openssl verify -CAfile path/to/ca-cert.pem path/to/foo-cert.pem

