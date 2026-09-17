Feature: cert
  Manage X.509 certificates



Background:

  Given all sample certificates have been cleaned



Scenario Outline: Generate files for certificate config template `{file}.cert.conf.tmpl`

  Then template file `<file>.cert.conf.tmpl` should exist
  But config file `<file>.cert.conf` should not exist

  When I run `tp cert init "<file>.cert.conf.tmpl"`
  Then the command should succeed
  And config file `<file>.cert.conf` should exist
  But private key file `<private>.key.pem` should not exist
  And key passphrase file `<private>.key.pass.txt` should not exist
  And CSR file `<file>.csr.pem` should not exist

  When I run `tp cert request <file>.cert.conf`
  Then the command should succeed
  And private key file `<private>.key.pem` should exist
  And key passphrase file `<private>.key.pass.txt` should exist
  And CSR file `<file>.csr.pem` should exist
  And CNs in CSR `<file>.csr.pem` and config `<file>.cert.conf` should match

  When I run `tp cert selfsign <file>.csr.pem`
  Then the command should succeed
  And self-signed X.509 certificate file `<file>.cert.pem` should exist
  And CNs in certificate `<file>.cert.pem` and CSR `<file>.csr.pem` should match

  Examples:
    | file                                   | private                                        |
    | ../cert/good/rsa-4096                  | ../cert/good/private/rsa-4096                  |
    | ../cert/good/ecdsa-256                 | ../cert/good/private/ecdsa-256                 |
    | ../cert/ugly/domain-multiple-wildcards | ../cert/ugly/private/domain-multiple-wildcards |
