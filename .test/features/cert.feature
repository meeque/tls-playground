Feature: cert
  Manage X.509 certificates



Scenario Outline: Generate files for certificate config template `{file}.cert.conf.tmpl`

  Given config file `<file>.cert.conf` does not exist
  But template file `<file>.cert.conf.tmpl` exists
  When I run `tp cert init "<file>.cert.conf.tmpl"`
  Then the command should succeed
  And `tp` should generate config file `<file>.cert.conf`

  Given CSR file `<file>.csr.pem` does not exist
  And private key file `<private>.key.pem` does not exist
  And key passphrase file `<private>.key.pass.txt` does not exist
  But config file `<file>.cert.conf` exists
  When I run `tp cert request <file>.cert.conf`
  Then the command should succeed
  And `tp` should generate private key file `<private>.key.pem`
  And `tp` should generate key passphrase file `<private>.key.pass.txt`
  And `tp` should generate CSR file `<file>.csr.pem`
  And CNs in CSR `<file>.csr.pem` and config `<file>.cert.conf` should match

  Given certificate file `<file>.cert.pem` does not exist
  But CSR file `<file>.csr.pem` exists
  And private key file `<private>.key.pem` exists
  And key passphrase file `<private>.key.pass.txt` exists
  And private key file `<private>.key.pem` exists
  And key passphrase file `<private>.key.pass.txt` exists
  When I run `tp cert selfsign <file>.csr.pem`
  Then the command should succeed
  And `tp` should generate self-signed X.509 certificate file `<file>.cert.pem`
  And CNs in certificate `<file>.cert.pem` and CSR `<file>.csr.pem` should match

  Examples:
    | file                                   | private                                        |
    | ../cert/good/rsa-4096                  | ../cert/good/private/rsa-4096                  |
    | ../cert/good/ecdsa-256                 | ../cert/good/private/ecdsa-256                 |
    | ../cert/ugly/domain-multiple-wildcards | ../cert/ugly/private/domain-multiple-wildcards |
