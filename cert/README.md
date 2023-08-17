# TLS Playground Certificate Utilities

This TLS Playground module implements utilities for dealing with [X.509 certificates (cert)](https://www.rfc-editor.org/rfc/rfc5280) and [Certificate Signing Requests (CSR)](https://www.rfc-editor.org/rfc/rfc2986) as used in the context of TLS.

The TP Certificate Utilities can be controlled through the `tp cert` command of the TP CLI.
Most of the functionality is implemented by invoking commands of the [OpenSSL](https://www.openssl.org/) CLI tool.
Observe the outputs of the TP CLI to find out how it makes use of `openssl`.



## Certificate Utilities Usage

You may never need to use the TP certificates utilities explicitly.
Other TP modules make heavy use of this module under the hood.
These will print infos about what's going on, in particular the relevant *OpenSSL* commands.

### Creating Certificate Signing Requests (CSR)

The main purpose of the TP certificate utilities is creating Certificate Signing Requests (CSR, colloquially request or just req).
These CSRs can then be signed by a Certificate Authority (CA).
More formally, a CA will create an *X.509* cert that contains data from the CSR and sign this cert with its own private key.
Data contained in a CSR includes:

* Information about the "subject" of the desired cert, e.g. the DNS name of a server.
* Desired validity period and other metadata.
* Information about an asymmetric key pair, in particular the public key itself.
* A signature that proves that the creator of the CSR owns the private key that matches the above public key.

Notably, a CSR does **not** contain the private key itself.
Like certs, CSRs do not need to be kept confidential.
However, the matching private key **must** be kept confidential.

CSRs are stored in the standard *PKCS #10* file format, which is somewhat similar to the *X.509* format used for certs themselves.
TP uses the PEM flavor of CSR files whenever possible.

In order to specify the data in a CSR, TP makes use of [OpenSSL's INI-like config file format](https://www.openssl.org/docs/man3.1/man5/config.html).
In particular, TP makes use of [the configuration options of the `req` section](https://www.openssl.org/docs/man3.1/man1/openssl-req.html#CONFIGURATION-FILE-FORMAT), as used for the `openssl req` command.
These `openssl` config files can also specify some properties of the associated key pair, e.g. the size of an [RSA](https://en.wikipedia.org/wiki/RSA_(cryptosystem)) key.
Unfortunately, `openssl` config files cannot be used to specify all key pair properties that OpenSSL supports.
In particular, properties of [Elliptic Curve Digital Signature Algorithm (ECDSA)](https://en.wikipedia.org/wiki/Elliptic_Curve_Digital_Signature_Algorithm) key pairs must be specified in a separate key parameters file.
TP certificate utilities make use of [TP file naming conventions](../bin/README.md#file-naming-conventions) for looking up CSR config files (and optional key parameter files).

As mentioned above, a CSR always contains a public key.
OpenSSL provides dedicated commands for generating asymmetric key pairs for different asymmetric ciphers, such as RSA or ECDSA.
However, the `openssl req` command can also generate a new key pair and a CSR based on this key pair in one go.
For the sake of simplicity TP certificate utilities use this latter approach when creating a CSR.

This also means that TP will use a newly generated key pair for each new CSR, even when working with a CSR config files for which it has previously generated a key pair.
This is considered best-practice, though reusing the same key pair for multiple CSRs (and ultimately certs) is technically posible.

Finally, here is how to generate a CSR based on one of the CSR config files that come with TP:

```
tp cert sign server/nginx-simple/tls/server.cert.conf
```

Based on the `server.cert.conf` file (and the `server.key.params.pem`) right next to it, this generates the following files:

```
server/nginx-simple/tls/server.csr.pem
server/nginx-simple/tls/private/server.key.pem
server/nginx-simple/tls/private/server.key.pass.txt
```

### Self-Signing Certificates

TODO explain purpuse of self-signed certs and their legitimacy

TODO explain that this can take either a config file or an existing CSR as input

TODO show example command and resulting files

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

### Sample Certificates



## TP Certificate Commands Reference

```
Summary:   TLS Playground Certificate Utilities

Usage:     tp [<global options>] cert <command> <file> [<file> ...]

Available Commands:

  init         Initialize cert config files, where necessary.

  show         Show contents of a cert, CSR, or key <file> in human-readable form.

  fingerprint  Calculate fingerprint of a cert, CSR, or key <file>.

  request      Create a key-pair and a CSR based on a config <file>.

  selfsign     Create a self-signed certificate based on a config <file> file or an existing CSR <file>.

  pkcs8        Convert a private key <file> into PKCS8 format.

  pkcs12       Bundle private key <file> and cert <file> into a PKCS12 file.

  clean        Clean up cert <file> and related files.

Arguments:

  <file>  Path to a cert, CSR, key, 'openssl req' config file, or directory. May be absolute or relative.
          When a directory path is given, tp will search for all suitable files in that directory.
          When multiple files and directories are given, the command will run on all of them consecutively.
          Commands that support multiple file types ('show', 'fingerpint') will deduce file type from naming conventions.
          Run 'tp --help files' to learn more about naming conventions for certificate files.

Global Options:

  Run 'tp --help' to learn more about global options, in particular the '--step' option.

Environment:

  Set ${TP_PASS} to conigure the passphrase for private key files encryption.
  Set ${TP_SERVER_DOMAIN} to control the base domain name of some sample certificates.

  Run 'tp --help env' to learn more about this env-var.
```
