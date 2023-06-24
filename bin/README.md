# The TLS Playground Commands

The TP commands are the main tool for using the TLS playground.
Assuming that your copy of TP is located at `${tp_base_dir}`, you can find the TP commands executable at `${tp_base_dir}/bin/tp`.
Consider adding this directory to your `${PATH}` env-var.

You can invoke TP commands from everywhere and most file arguments are interpreted relative to the current working directory.
However, some TP commands reference some files relative to the `${tp_base_dir}`.



## Command Summary

```
Usage: tp [<global options>] <command> [...]

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

  TP_PASS   The passphrase for encrypt key files.

  TP_COLOR  Control colored terminal outputs.
            Set to non-empty to force colors.
            Set to empty string to suppress colors.
            Leave unset to let TP decide to use colors depending on terminal support.

Global config files:

  ${tp_base_dir}/.tp.pass.txt  Use this password to encrypt key files (ignored, if TP_PASS is set)

Directories:

  tp_base_dir  the base directory where the TLS Playground is located. I.e. the parent of the directory that contains the 'tp' script.
```


## CLI Phylosophy

The main purpose of the TP is educational.
All TP commands follow consistent usage patterns and tell the user exactly what is going on.

TP will print relevant commands and all their arguments before actually running them.
This focuses on commands that are directly dealing with certificates and TLS, in particular [openssl](https://www.openssl.org/) and [certbot](https://certbot.eff.org/).
Less interesting part, e.g. file operations, are usually not printed verbatim, but summarized in a brief output message.

TODO mention --step option again
TODO explain use of config files for openssl
TODO explain tls vs. ssl terminology

TODO segway to opinionated file naming


## File Naming Conventions

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

