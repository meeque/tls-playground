# TLS Playground Certificate Utilities



## TP CA Command Reference

```
Summary:   TLS Playground Certificate Utilities

Usage:     tp [<global options>] cert <command> <file> 

Available commands:

  show         Show contents of a cert, CSR, or key <file> in human-readable form.

  fingerprint  Calculate fingerprint of a cert, CSR, or key <file>.

  request      Create a certificate signing request based on a config <file>.

  selfsign     Create a self-signed certificate based on a config <file> file or an existing CSR <file>.

  pkcs8        Convert a private key <file> into PKCS8 format.

  pkcs12       Bundle private key <file> and cert <file> into a PKCS12 file.

  clean        Clean up cert <file> and related files.

Arguments:

  <file>  Path to a cert, CSR, key, or 'openssl req' config file.
          Commands that support multiple file types will deduce it from naming conventions:

          "${name}.cert.conf"
          "${name}.key.params.pem"
          "${name}.key.pem"
          "${name}.key.pass.txt"
          "${name}.csr.pem"
          "${name}.cert.pem"
          "${name}.chain.pem"
          "${name}.fullchain.pem"

          TODO document dirs
```


## Certificate Usage

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

