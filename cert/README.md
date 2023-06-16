# The TLS Playground Certificate Commands

## Commands Summary

```
Usage: tp [<global opions>] cert <command> <file> 

Available commands:

  show         Show contents of a cert, CSR, or key <file> in human-readable form.
  fingerprint  Calculate fingerprint of a cert, CSR, or key <file>.
  request      Create a certificate signing request based on a config <file>.
  selfsign     Create a self-signed certificate based on a config <file> file or an existing CSR <file>.
  pkcs8        Convert a private key <file> into PKCS8 format.
  pkcs12       Bundle private key <file> and cert <file> into a PKCS12 file.
  clean        Clean up cert <file> and related files.

Arguments:

  <file>  Path to a cert, CSR, key, or openssl cert config file.
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



