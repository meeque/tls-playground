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
This can be done with the `tp cert request` command.
The resulting CSRs can then be signed by a Certificate Authority (CA), or can be self-signed, as described in the next section.

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
tp cert request server/nginx-simple/tls/server.cert.conf
```

Based on the `server.cert.conf` file (and the `server.key.params.pem`) right next to it, this generates the following files:

```
server/nginx-simple/tls/server.csr.pem
server/nginx-simple/tls/private/server.key.pem
server/nginx-simple/tls/private/server.key.pass.txt
```

In the above example, `server.key.pass.txt` contains an encryption-at-rest passphrase that protects the private key file.
This is a copy of the `${TP_PASS}` env-var at the time the key has been generated.
Obviously, any software (e.g. a web server) that wants to make use of the certificate needs to have access to both the private key itself and its passphrase.
Nevertheless, it is good practice to encrypt private keys with a strong passphrase.
This gives some protection in case the private key file gets exposed by accident, but only if the passphrase remains confidential.

### Self-Signing Certificates

A CSR is just a means to an end, what we actually want is an X.509 certificate.
The easiest way to create a cert from a CSR is self-signing, using the `tp cert selfsign` command.
For other cert signing options, see the [TP Demo CAs](../ca/README.md) and the [TP ACME Utilities](../acme/README.md).

At first, the notion of self-signing may seem odd.
It does not involve any Certificate Authority (CA) that would verify the claims that the CSR (and the resulting cert) makes.
It's like giving yourself a medal.
However, self-signed certificates do have legitimate use-cases, in particular in smaller, closed scenarios.
In such scenarios, it is possible to distribute certs (or their fingerprints) to all systems that need to validate them.
If done through a secure, out-of-band channel, usage of self-signed certs for TLS can be perfectly secure.

To create a self-signed cert from an existing CSR, run the following:

```
tp cert selfsign server/nginx-simple/tls/server.csr.pem
```

This command will use TP file naming conventions to find a matching private key file (`.key.pem`) and key passphrase file (`.key.pass.txt`).
A private key is necessary to create a digital signature over the contents of the new cert.
For self-signed certificates, this is (by definition) the private key that matches the public key in the CSR and in the resulting cert.

For convenience, TP certificate utilities allow you to create a CSR and a self-signed certificate through a single command.
Simply pass an OpenSSL CSR config file to the command, instead of an existing CSR:

```
tp cert selfsign server/nginx-simple/tls/server.cert.conf
```

This invokes `tp cert request` (see previous section) under the hood and then uses the resulting CSR and private key to create a self-signed cert.
In the end, both of the above examples will create the following new files:

```
server/nginx-simple/tls/server.cert.pem
server/nginx-simple/tls/server.chain.pem
server/nginx-simple/tls/server.fullchain.pem
```

The new certificate itself will be in the `.cert.pem` file.
The other two files are chain files that can be useful for configuring TLS servers or clients to use the certificate.
However, for self-signed certificates have a fixed cert chain length of one.
Therefore, the above example creates an empty `.chain.pem` file and a `fullchain.pem` file that only contains the self-signed cert itself.

### Inspecting Certificates and Related Files

The above commands show a textual version of the CSR respectively the cert after creating it.
They also show a cryptographic checksum (a.k.a. fingerprint) of the cert.

You can also show file contents later, by using the `tp cert show` command.
Just like other TP commands, this will determine how to show the file based on TP file naming conventions.
The following command shows the contents of both the CSR and the cert created in the previous sections:

```
tp cert show server/nginx-simple/tls/server.csr.pem server/nginx-simple/tls/server.cert.pem
```

Similarly you can show the fingerprint of the cert with this command:

```
tp cert fingerprint server/nginx-simple/tls/server.cert.pem
```

### Sample Certificates

TODO

## TP Certificate Commands Reference

```
Summary:   TLS Playground Certificate Utilities

Usage:     tp [<global options>] cert <command> <file> [<file> ...]

Available Commands:

  init         Initialize a cert config <file>, where necessary.

  show         Show contents of a cert, CSR, or key <file> in human-readable form.

  fingerprint  Calculate a cryptographic checksum (a.k.a. fingerprint) of a cert, CSR, or key <file>.

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
