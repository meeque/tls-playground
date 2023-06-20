# The TLS Playground Commands

## Commands Summary

```
Usage: tp [<global options>] <command> [...]

Available commands:

  cert     manage keys, CSRs, certificates, etc.
  ca       manage and use built-in private Certificate Authorities (CAs)
  acme     obtain and manage certificates from external CAs using the ACME protocol
  server   use sample servers with certificates and TLS
  clean    clean all transient data

Global options:

  -h, --help  print this global help text or command help texts
              run 'tp <command> --help' to learn more about individual commands and their arguments

  -s, --step  step through invocation of external commands (e.g. openssl, certbot)

Global environment variables:

  TP_PASS   use this passphrase to encrypt key files

  TP_COLOR  set to non-empty to force colored outputs
            set to empty to suppress colors
            if absent, determine color output based on terminal support

Global config files:

  ${tp_base_dir}/.tp.pass.txt  use this password to encrypt key files (ignored, if TP_PASS is set)

Directories:

  tp_base_dir  the base directory where the TLS Playground is located. I.e. the parent of the directory that contains the 'tp' script.
```
