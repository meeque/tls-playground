# TLS Playground Demo CAs

This TLS Playground component implements opinionated, easy to use, but incomplete Certificate Authorities (CAs). It is based on `openssl ca` and other `openssl` commands.

These CAs are not intended for production use, or even for use in a public facing test scenario. It lacks important CA features, like domain ownership verification and certificate revocation. Also, it uses a default passphrase to protect certificate keys.



## `ca` Commands Summary

You can control and utilize the TP CAs with the `tp ca` command:

```
Usage: tp [<global options>] ca <command> [<ca>] [<request>]

Available commands:

  init        Initialize given <ca>, or all TP CAs, if <ca> is omitted.
              Initialization includes creating the necessary directory structures,
              generating a CA root certificate and its private key, creating an
              empty cert DB, etc.

  sign        Sign given <request> with given <ca>.
              Both <ca> and <request> are mandatory for the sign command.
              Signed cert files will be placed next to the <request>.

  clean       Clean up given <ca>, or all TP CAs, if <ca> is omitted.
              Clean up includes deletion of all transient CA files, such as the
              CA root certificate and its private key, the cert DB and the cert archive.

Arguments:

  <ca>        Name of a TP CA.
              Each TP CA is represented by a sub-directory of ${tp_base_dir}/ca/.
              The name of this sub-directory is also the name of the CA.

  <request>   The request to sign.
              This can be either a Certificate Signing Request (CSR) file or
              an 'openssl req' configuration file. If it's the latter,
              the CSR will be generated on the fly before signing.
```



## CA Usage

### Initializing the CA

TP comes with several demo CAs, which are located `${tp_base_dir}/ca/` directory.
Each CA comes with a few static config files that specify the CA's behavior and its root certificate.
During operation, each CA will need a few other, which it manages in its own directory.
CA initialization will put all the necessary files and directories in place.
You can run initialization for individual CAs, or for all of them at once:

```
tp ca init
```

The most important step in CA initialization is the creation of a **CA root certificate**.
As with other TP certificates, initialization creates the CA root certificate based on an `openssl req` configuration file.
This is exactly the same as running `tp cert sign` to create a new certificate.

Note that this creates a **self-signed certificate**, which is the standard for both public and private CAs.
However, a couple o things distinguish CA root certificates from self-signed certificates that you would use for a server:

1. The certificate subject DN does not contain a DNS domain name.
The CN field simply contains some informal descriptive name.

2. The certificate has an `X509v3 Basic Constraints` extension that says `CA:TRUE`.
Server certificates say `CA:FALSE`, or may omit the extension altogether.

The latter is very important when verifying certificate chains.
If the chain contains a signature from an issues whose certificate does not have `CA:TRUE`, the verification must fail.
In other words, only the leaf certificate may have `CA:FALSE` or omit the extension altogether, but intermediate and root certificates must have `CA:TRUE`.
Note that the TP demo CAs do not make use of intermediate certificates.



### Signing Certificates with the CA

TODO

### Cleaning Up the CA

TODO



XXX delete below here

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

