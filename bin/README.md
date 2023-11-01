# TLS Playground CLI

The TP CLI is the main tool for using the TLS playground, which demonstrates usage of certificates and TLS.
Assuming that your copy of TP is located at `${tp_base_dir}`, you can find the TP commands executable at `${tp_base_dir}/bin/tp`.
Consider adding this directory to your `${PATH}` env-var.

You can invoke TP commands from anywhere, and most file arguments are interpreted relative to the current working directory.
However, some TP commands reference some files relative to the `${tp_base_dir}`.



## TP CLI Philosophy

The main purpose of TP is educational.
All TP commands follow consistent usage patterns and tell you exactly what is going on.

TP will print relevant external tools and all their arguments before actually running them.
This focuses on tools that are dealing with TLS and certificates, in particular [OpenSSL](https://www.openssl.org/) and [Certbot](https://certbot.eff.org/).
Less interesting external tool invocations, such as trivial file operations, are usually not printed verbatim, but summarized in a brief message.

### OpenSSL Usage

TP makes heavy use of the *OpenSSL* CLI tool and the underlying library.
*OpenSSL* is the swiss-army-knife for dealing with TLS, cryptographic algorithms, keys, certificates, etc.

The *OpenSSL* CLI provides dozens of sub-commands, each with dozens of arguments.
These will satisfy most of your TLS needs right there on the command line.
However, there are certain situations where CLI arguments are not enough *OpenSSL* requires configuration files or interactive user inputs.
This is often the case in situations where CLI aguments would be unwieldy, e.g. when specifying domains for a multi-domain certificates.

For a more consistent experience, TP makes use of *OpenSSL* configuration files as much as possible.
Even in situations where the use of CLI arguments would be sufficient.
TP will usually print a configuration file before passing it to *OpenSSL*, so you'll know what exactly is going on.

TP tries to avoid *OpenSSL* usage that would require user interaction.
It avoids any other user interaction for that matter, except in *step mode*, as described next.

### TP Step Mode

Many TP commands produce a lot of outputs, which can be overwhelming.
Use the `--step` option to slow things down a little.
This will cause TP to pause before running an external tool.
And after it has run, so that you can inspect its outputs.
Continue by pressing any key.



## TP Terminology Conventions

Some terminology around TLS can be rather confusing, especially to newcomers.
To reduce this confusion, TP tries to stick to the following terminology conventions.

### SSL vs. TLS

Technically, the acronym **SSL (Secure Socket Layer)** denotes the predecessor of **TLS (Transport Layer Security)**.
All versions of SSL have been deprecated years ago, as have older versions of TLS.
The SSL and TLS version history goes like this, in chronological order:

* **SSL 1.0** (internal draft only)
* **SSL 2.0** (insecure and deprecated)
* **SSL 3.0** (insecure and deprecated)
* **TLS 1.0** (insecure and deprecated)
* **TLS 1.1** (insecure and deprecated)
* **TLS 1.2** (deemed secure for some supported [cipher suites](https://en.wikipedia.org/wiki/Cipher_suite))
* **TLS 1.3** (deemed secure for all supported cipher suites)

In practice, the terms SSL and TLS are often used as synonyms, not to denote specific versions.
Consequently, the outdated acronym SSL is still used widely today.
E.g. the [OpenSSL](https://www.openssl.org/) library and CLI tool have clinched to the SSL label even though they have supported TLS for ages.

When configuring clients or servers for TLS, you will also encounter the term SSL frequently.
E.g. in the names of CLI arguments, configuration variables, etc.
In most cases, SSL is meant to include both SSL and TLS in these contexts.
However, there are exceptions to this rule, so read the documentation carefully!

TP follows common practice and uses **SSL and TLS as synonyms**, but **prefers the term TLS** wherever possible.

### X.509 Certificates

The [X.509](https://en.wikipedia.org/wiki/X.509) [standard](https://www.itu.int/rec/T-REC-X.509/en) specifies certificates and related data structures and file formats.
X.509 certificates play a crucial role in TLS by allowing clients to verify the identity of a server.
(And optionally, allowing servers to very the identity of a client.)
In fact, certificates are so crucial to TLS that most of the TLS Playground and the TP CLI deal with certificates, rather than with the TLS protocol itself.

As you may have noticed by now, the term *X.509 certificate* is somewhat unwieldy.
Therefore it is often abbreviated *certificate* or just *cert*.
Less commonly, it may be abbreviated to *X.509*, *x509*, or similar.

TP follows common practice uses all these terms interchangeably.
However, it prefers **certificate** in prose and **cert** in more technical contexts, such as in the file names described in the next section.

### File Naming Conventions

If you've ever worked with certificates before, you have probably encountered a confusing number of filename extensions.
These may have included `.key`, `.csr`, `.req`, `.crt`, `.p12`, `.pfx`, `.der`, `.pem`, and similar.

Some of these extensions denote different **file types** (technically types of data-structues inside the file), while others denote different **file encoding formats**.
Confusion arises, because most extensions only tell you one of these, but not the other.
TP tries to address this by using two levels of filename extensions, which together denote both type and encoding.

#### File Types

These are the most important file types that TP uses, with their TP filename extensions in parentheses:

* **cryptographic parameters** (`.params`)
* **cryptographic keys** (`.key`)
* **certificate signing requests (CSR)** (`.csr`)
* **certificates** (`.cert`)
* **certificate chains** (`.chain`, `.fullchain`)

On top of this, you may encounter several tool-specific configuration files, mostly in text-based formats.
TP uses filename extensions `.conf` or `.ini` for most of these.

#### File Encoding Formats

At a logical level, most of the above file types are defined in terms of an interface description language called [Abstract Syntax Notation One (ASN.1)](https://en.wikipedia.org/wiki/ASN.1).
However, *ASN.1* can be serialized using different encoding formats.
In the context of TLS, the most important encoding formats are:

* **[Distinguished Encoding Rules (DER)](https://en.wikipedia.org/wiki/X.690#DER_encoding):**
A binary format, which is also used to transmit certificates over the network during a TLS handshake.
TP uses the customary filename extension `.der` for this format.

* **[Privacy-Enhanced Mail (PEM)](https://en.wikipedia.org/wiki/Privacy-Enhanced_Mail):**
A text format that is based on base64-encoded **DER** data, broken into multiple lines for better readability.
*PEM* also adds textual headers and footers that denote the file type.
TP uses the customary filename extension `.pem` for this format.

You will easily recognize a *PEM* file by its contents, if you've ever seen one before.
Here is an example *PEM* file that contains a certificate:

```
-----BEGIN CERTIFICATE-----
MIICnzCCAiYCFCsGO6CQATt0rZV8yyU2crhMoY5hMAoGCCqGSM49BAMCMIGzMQsw
CQYDVQQGEwJERTEQMA4GA1UECAwHQmF2YXJpYTEPMA0GA1UEBwwGTXVuaWNoMRcw
FQYDVQQKDA5UTFMgUGxheWdyb3VuZDEmMCQGA1UECwwdWW91IGhhdmUgZm91bmQg
YW4gRWFzdGVyIEVnZyExQDA+BgNVBAMMN0JlIHRoZSBmaXJzdCBvbmUgdG8gcmVw
b3J0IHRoaXMgYW5kIHdpbGwgYnV5IHlvdSBCZWVycyEwHhcNMjMwNzE2MjAwMDQ4
WhcNMjMxMDE0MjAwMDQ4WjCBszELMAkGA1UEBhMCREUxEDAOBgNVBAgMB0JhdmFy
aWExDzANBgNVBAcMBk11bmljaDEXMBUGA1UECgwOVExTIFBsYXlncm91bmQxJjAk
BgNVBAsMHVlvdSBoYXZlIGZvdW5kIGFuIEVhc3RlciBFZ2chMUAwPgYDVQQDDDdC
ZSB0aGUgZmlyc3Qgb25lIHRvIHJlcG9ydCB0aGlzIGFuZCB3aWxsIGJ1eSB5b3Ug
QmVlcnMhMHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEqD0WbFB78pXGo0rGdmGTLQF0
qbQkFHTGm6oVAknHcTb4HmnhXc+PduTd2b9p7Gqzf++V+b4Q0Rfa3PqPdQr/NsVf
kbqkjbTpPzihKMJO7SAFr4EyoFbUoVcP0Ns9NraaMAoGCCqGSM49BAMCA2cAMGQC
MA64tXok3S9E/OAPaiDmuT19Hyf16669RV3D20hXLTcttrriQW98Go6+Qr+KDvoU
/wIwWyKP+6Do19Pk5wTUSlq3CtD43qEYHRwXAeSofqqr4KBKW1uYDiGraupIcIWL
JPsj
-----END CERTIFICATE-----
```

TP prefers *PEM* over *DER* whenever possible.



## TP Commands Reference

```
Summary:   TLS Playground CLI

Usage:     tp [<global options>] <command> [...]

Available commands:

  cert     Manage keys, CSRs, certificates, etc.

  ca       Manage and use built-in private Certificate Authorities (CA).

  acme     Obtain and manage certificates from external CAs using the ACME protocol.

  server   Use demo servers with certificates and TLS.

  clean    Delete transient data.

Global options:

  -s, --step  Step through invocation of external commands (e.g. openssl, certbot) one-by-one.

  --disclose  Disclose confidential information such as private keys to stdout, i.e. to the console.
              Without this option, no confidential data will be disclosed.

  -h, --help  Print this global help text, a command help text, or a topic help text.
              Run 'tp --help <command>' to learn more about individual commands and their arguments.
              Run 'tp --help env' to learn more about supported environment variables.
              Run 'tp --help files' to learn more about files and file naming conventions.
```

### Environment Variables

```
  TP_PASS   The passphrase for encrypting private key files.
            Defaults to the contents of file .tp.pass.txt in ${tp_base_dir}.
            Run 'tp --help files' to learn more about this global configuration file.

  TP_SERVER_DOMAIN
            The base FQDN (fully qualified domain name) for the demo servers and
            their certificates.
            Some demo servers may be using hard-coded sub-domains of this domain
            rather than the FQDN itself.
            Defaults to localhost. When working with ACME certificates, you will
            have to change it to your own public DNS domain.

  TP_SERVER_LISTEN_ADDRESS
            The local address that TP demo servers and the TP ACME challenges
            web-server will listen to.
            To access a demo server over the Internet and to resolve ACME http-01
            challenges from a public CA, change this to a local address that receives
            traffic from the Internet.
            Defaults to 127.0.0.1 (localhost), for the sake of attack surface
            reduction. Use 0.0.0.0 to listen on all local addresses.

  TP_SERVER_HTTP_PORT
            The local TCP port to which the TP ACME challenges web-server will
            listen for plain http connections.
            Defaults to unprivileged port 8080, to allow local testing without
            root privileges. If this is not a concern, consider changing it to the
            http default port, 80, or establish some sort of port forwarding.
            To resolve ACME http-01 challenges from a public CA, the challenges
            web-server must be reachable at port 80 from the Internet.

  TP_SERVER_HTTPS_PORT
            The local TCP port to which TP demo servers will listen for
            TLS-protected https connections.
            Defaults to unprivileged port 8443, to allow local testing without
            root privileges. If this is not a concern, consider changing it to the
            https default port, 443, or establish some sort of port forwarding.

  TP_ACME_SERVER_URL
            Use this base URL to contact the ACME server.
            Must be a formally valid https URL, or one of the following presets:
              - le, letsencrypt, lets-encrypt:
                -> https://acme-v02.api.letsencrypt.org/directory
              - les, letsencryptstaging, lets-encrypt-staging:
                -> https://acme-staging-v02.api.letsencrypt.org/directory
            Defaults to lets-encrypt-staging.
            Note that consecutive TP ACME commands may not work as expected,
            if you change this URL in-between.

  TP_ACME_ACCOUNT_EMAIL
            Use this email address when registering an ACME account.
            The ACME server does not perform email address verification, but it
            may send notification emails to this address, e.g. certificate
            expiration warnings.
            Defaults to an invalid example address with an .example domain name.

  TP_COLOR  Control colored terminal outputs.
            Set to non-empty to force colors.
            Set to empty string to suppress colors.
            Leave unset to let TP decide to use colors depending on terminal support.
```

### Filenames and Extensions

```
Certificate specification files:

  Static files that are part of TP, but can be customized.

  .cert.conf       An OpenSSL configuration file that specifies certificate contents and parameters.
                   It affects generated key files, Cetificate Signing Requests (CSR), and Certificates.

  .key.params.pem  A file that contains cryptographic key parameters in PEM format, as used by OpenSSL.
                   This is necessary for cryptographic paramaters that cannot be provided as CLI arguments
                   or in text-based OpenSSL config files.
                   Typically used to specify curves for elliptic-curves cryptography (EC).

Certificate key files:

  Transient files that store generated keys and related data.
  TP always stores them in a 'private/' directory, relative to Certificate specification files.
  TP sets file system permission to restrict all access to the file owner.

  .key.pem         A private key file in PEM format.

  .key.pass.txt    The encryption-at-rest passphrase that protects the private key file.
                   This is a copy of ${TP_PASS} env-var at the time the key has been generated.

Certificate related files:

  Transient files that store generated Cetificate Signing Requests (CSR) and Certificates.

  .csr.pem         A Certificate Signing Request (CSR) in PEM format.

  .cert.pem        A Certificate in PEM format.

  .fullchain.pem   A Certificate chain file that contains a Certificate and transitively
                   all Certificates that signed it.
                   The order is from the Certificate itself (a.k.a. leaf Certificate) up to a root Certificate.
                   For self-signed certificates, this will only contain the Certificate itself.
                   The file is in PEM format, which is simply a concatenation of all the Certificates in PEM format.

  .chain.pem       A Certificate chain file that contains all Certificates that transitively signed a Certificate.
                   Very similar to .fullchain.pem, but does NOT contain the leaf Certificate itself.
                   This is useful because some applications expect the leaf Certificate and the rest of the chain in separate files.

Alternative certificate files:

  Transient files that contain keys and Certificates in alternative formats.
  TP stores them in a 'private/' directory, like other files that contain keys, see above.

  .key.pkcs8.der   A PKCS8 encoded private key in DER format.
                   This is usefull for import into some applications, such as Java key stores.

  .pfx             A PKCS12 bundle that contains a certificate and associated private key.
                   This is usefull for import into some applications.

Other configuration files:

  Static files that contain various configuration data.

  .conf            Configuration files for various TP components, such as CAs, Certbot, or nginx demo servers.
  .ini

  .tmpl            Configuration file templates.
  .cert.conf.tmpl  TP CLI 'init' commands will process these files and use envsubst to replace placeholders
  .conf.tmpl       with the values of respective environment variables.
  .ini.tmpl        TP will place the result into a file with the same name, but with the .tmpl extension removed.
                   TP CLI 'clean' commands will remove all files that have been generated from a configuration file template.
                   In other words, the generated file will be treated as a transient file and only the template itself will
                   be treated as a static file.

Global config files:

  Static configuration files for TP as a whole.
  These files reside in ${tp_base_dir} this is the base directory where the TP is located,
  that is the parent of the directory that contains the 'tp' script.
  Note that setting an env-var with the same name will not affect '${tp_base_dir}'.
  TP always determins it relative to the 'tp' script.

  .tp.pass.txt     Passphrase to encrypt key files.
                   Ignored, if ${TP_PASS} env-var is set.
                   If neither the env-var nor this file exist, 'tp' will generate a new passphrase and store it in this file.

  .bashrc          Recommended bash configuration for running TP demos.
                   Puts the TP CLI tool on the ${PATH} and configures a minimalistic [TP] prompt amongst other tweaks.
                   Source it into your shell by running '. .bashrc'

  README.md        Entry-point to the TP documentation, best viewed in a markdown editor or viewer.
                   Should work nicely with built-in markdown viewers of Github and other repository servers.
```
