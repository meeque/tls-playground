Feature: cert
  Manage X.509 certificates



Background:

  Given all sample certificates have been cleaned



Scenario Outline: Generate self-signed certificate `<path>/<name>.cert.pem` and clean up afterwards

  Then template file `<path>/<name>.cert.conf.tmpl` should exist
  But config file `<path>/<name>.cert.conf` should NOT exist
  And private key file `<path>/private/<name>.key.pem` should NOT exist
  And key passphrase file `<path>/private/<name>.key.pass.txt` should NOT exist
  And CSR file `<path>/<name>.csr.pem` should NOT exist
  And self-signed X.509 certificate file `<path>/<name>.cert.pem` should NOT exist

  When I run `tp cert init "<path>/<name>.cert.conf.tmpl"`
  Then the command should succeed
  And config file `<path>/<name>.cert.conf` should exist

  When I run `tp cert selfsign <path>/<name>.cert.conf`
  Then the command should succeed
  And private key file `<path>/private/<name>.key.pem` should exist
  And key passphrase file `<path>/private/<name>.key.pass.txt` should exist
  And CSR file `<path>/<name>.csr.pem` should exist
  And self-signed X.509 certificate file `<path>/<name>.cert.pem` should exist
  And CNs in CSR `<path>/<name>.csr.pem` and config `<path>/<name>.cert.conf` should match
  And CNs in certificate `<path>/<name>.cert.pem` and CSR `<path>/<name>.csr.pem` should match

  When I run `tp cert clean <path>/<name>.cert.pem`
  Then the command should succeed
  And config file `<path>/<name>.cert.conf` should NOT exist
  And private key file `<path>/private/<name>.key.pem` should NOT exist
  And key passphrase file `<path>/private/<name>.key.pass.txt` should NOT exist
  And CSR file `<path>/<name>.csr.pem` should NOT exist
  And self-signed X.509 certificate file `<path>/<name>.cert.pem` should NOT exist
  But template file `<path>/<name>.cert.conf.tmpl` should exist

  Examples:
    | path         | name                      |
    | ../cert/good | rsa-4096                  |
    | ../cert/good | ecdsa-256                 |
    | ../cert/ugly | domain-multiple-wildcards |



Scenario Outline: Generate self-signed certificate `<path>/<name>.cert.pem` step by step

  Then template file `<path>/<name>.cert.conf.tmpl` should exist
  But config file `<path>/<name>.cert.conf` should NOT exist

  When I run `tp cert init "<path>/<name>.cert.conf.tmpl"`
  Then the command should succeed
  And config file `<path>/<name>.cert.conf` should exist
  But private key file `<path>/private/<name>.key.pem` should NOT exist
  And key passphrase file `<path>/private/<name>.key.pass.txt` should NOT exist
  And CSR file `<path>/<name>.csr.pem` should NOT exist

  When I run `tp cert request <path>/<name>.cert.conf`
  Then the command should succeed
  And private key file `<path>/private/<name>.key.pem` should exist
  And key passphrase file `<path>/private/<name>.key.pass.txt` should exist
  And CSR file `<path>/<name>.csr.pem` should exist
  And CNs in CSR `<path>/<name>.csr.pem` and config `<path>/<name>.cert.conf` should match
  But self-signed X.509 certificate file `<path>/<name>.cert.pem` should NOT exist

  When I run `tp cert selfsign <path>/<name>.csr.pem`
  Then the command should succeed
  And self-signed X.509 certificate file `<path>/<name>.cert.pem` should exist
  And CNs in certificate `<path>/<name>.cert.pem` and CSR `<path>/<name>.csr.pem` should match

  Examples:
    | path         | name                      |
    | ../cert/good | rsa-4096                  |
    | ../cert/good | ecdsa-256                 |
    | ../cert/ugly | domain-multiple-wildcards |



Scenario Outline: Fail generating self-signed certificate from broken config `<path>/<name>.cert.config`

  Then template file `<path>/<name>.cert.conf.tmpl` should exist
  But config file `<path>/<name>.cert.conf` should NOT exist

  When I run `tp cert init "<path>/<name>.cert.conf.tmpl"`
  Then the command should succeed
  And config file `<path>/<name>.cert.conf` should exist
  But key passphrase file `<path>/private/<name>.key.pass.txt` should NOT exist
  And private key file `<path>/private/<name>.key.pem` should NOT exist
  And CSR file `<path>/<name>.csr.pem` should NOT exist
  And self-signed X.509 certificate file `<path>/<name>.cert.pem` should NOT exist

  When I run `tp cert request <path>/<name>.cert.conf`
  Then the command should fail
  And config file `<path>/<name>.cert.conf` should exist
  And key passphrase file `<path>/private/<name>.key.pass.txt` should exist
  But private key file `<path>/private/<name>.key.pem` should NOT exist
  And CSR file `<path>/<name>.csr.pem` should NOT exist
  And self-signed X.509 certificate file `<path>/<name>.cert.pem` should NOT exist

  When I run `tp cert selfsign "<path>/<name>.cert.conf.tmpl"`
  Then the command should fail
  And config file `<path>/<name>.cert.conf` should exist
  And key passphrase file `<path>/private/<name>.key.pass.txt` should exist
  But private key file `<path>/private/<name>.key.pem` should NOT exist
  And CSR file `<path>/<name>.csr.pem` should NOT exist
  And self-signed X.509 certificate file `<path>/<name>.cert.pem` should NOT exist

  Examples:
    | path        | name               |
    | ../cert/bad | rsa-short-key-404  |
