# TLS Playground CLI

TODO what is it good for?

The TP commands are the main tool for using the TLS playground.
Assuming that your copy of TP is located at `${tp_base_dir}`, you can find the TP commands executable at `${tp_base_dir}/bin/tp`.
Consider adding this directory to your `${PATH}` env-var.

You can invoke TP commands from anywhere.
Most file arguments are interpreted relative to the current working directory.
However, some TP commands reference some files relative to the `${tp_base_dir}`.



## TP CLI Philosophy

The main purpose of TP is educational.
All TP commands follow consistent usage patterns and tell you exactly what is going on.

TP will print relevant external tools and all their arguments before actually running them.
This focuses on tools that are dealing with TLS and cetificates, in particular [OpenSSL](https://www.openssl.org/) and [Certbot](https://certbot.eff.org/).
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



## Terminology

Some terminology around TLS can be rather confusing, especially to newcomers.
To reduce this confusion, TP tries to stick to the following terminology conventions.

### SSL vs. TLS

Technically, the acronym **SSL (Secure Socket Layer)** denotes the predecessor of **TLS (Transport Layer Security)**.
All versions of SSL have been deprecated years ago, as have older versions of TLS.
The SSL and TLS version history goes like this, in chronological order:

* **SSL 1** (internal draft only)
* **SSL 2** (insecure and deprecated)
* **SSL 3** (insecure and deprecated)
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



## File Naming Conventions

XXX The CAs use PEM as their standard file format. Wherever keys, certificate signing requests (CSRs), and certificates are involved they will be PEM encoded. For private keys, passphrase encryption is used, based on the value of environment variable `$TP_PASS`. If not specified in the environment, the passphrase defaults to `1234`.

TODO

.cert.conf
.key.parms.pem
.csr.pem
.cert.pem
.chain.pem
.fullchain.pem

.key.pem
.key.pass.txt


.der
.key.pkcs8.der
.pfx

.tmpl



## Command Summary

```
Summary:   TLS Playground CLI

Usage:     tp [<global options>] <command> [...]

Available commands:

  cert     Manage keys, CSRs, certificates, etc.

  ca       Manage and use built-in private Certificate Authorities (CAs).

  acme     Obtain and manage certificates from external CAs using the ACME protocol.

  server   Use sample servers with certificates and TLS.

  clean    Delete transient data.

Global options:

  -h, --help  Print this global help text or command help texts.
              Run 'tp <command> --help' to learn more about individual commands and their arguments.

  -s, --step  Step through invocation of external commands (e.g. openssl, certbot) one-by-one.

Global environment variables:

  TODO Gather docs for all env-vars in one place?

  TP_PASS   The passphrase for encrypting key files.

  TP_COLOR  Control colored terminal outputs.
            Set to non-empty to force colors.
            Set to empty string to suppress colors.
            Leave unset to let TP decide to use colors depending on terminal support.

Global config files:

  ${tp_base_dir}/.tp.pass.txt  Use this password to encrypt key files (ignored, if TP_PASS is set)

Directories:

  tp_base_dir  the base directory where the TLS Playground is located. I.e. the parent of the directory that contains the 'tp' script.
```

## Environment Variables

TODO collect env-var docs here, so they can be referenced from elsewhere
