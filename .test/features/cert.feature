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
  And TP should have printed "Generating key-pair and CSR..."
  And TP should have run command `<csr_command>`
  And TP should have printed "Signing CSR with it's own private key..."
  And TP should have run command `<selfsign_command>`
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
    | path         | name                      | csr_command                                                                                                                                                                                                                                                                    | selfsign_command                                                                                                                                                                                                                                                                                                     |
    | ../cert/good | rsa-4096                  | openssl req -new -config '../cert/good/rsa-4096.cert.conf' -passout 'file:../cert/good/private/rsa-4096.key.pass.txt' -keyout '../cert/good/private/rsa-4096.key.pem' -out '../cert/good/rsa-4096.csr.pem'                                                                     | openssl x509 -req -days 90 -copy_extensions copyall -sha512 -in '../cert/good/rsa-4096.csr.pem' -signkey '../cert/good/private/rsa-4096.key.pem' -passin 'file:../cert/good/private/rsa-4096.key.pass.txt' -out '../cert/good/rsa-4096.cert.pem'                                                                     |
    | ../cert/good | ecdsa-256                 | openssl req -new -config '../cert/good/ecdsa-256.cert.conf' -newkey 'param:../cert/good/ecdsa-256.key.params.pem' -passout 'file:../cert/good/private/ecdsa-256.key.pass.txt' -keyout '../cert/good/private/ecdsa-256.key.pem' -out '../cert/good/ecdsa-256.csr.pem'           | openssl x509 -req -days 90 -copy_extensions copyall -sha384 -in '../cert/good/ecdsa-256.csr.pem' -signkey '../cert/good/private/ecdsa-256.key.pem' -passin 'file:../cert/good/private/ecdsa-256.key.pass.txt' -out '../cert/good/ecdsa-256.cert.pem'                                                                 |
    | ../cert/ugly | domain-multiple-wildcards | openssl req -new -config '../cert/ugly/domain-multiple-wildcards.cert.conf' -passout 'file:../cert/ugly/private/domain-multiple-wildcards.key.pass.txt' -keyout '../cert/ugly/private/domain-multiple-wildcards.key.pem' -out '../cert/ugly/domain-multiple-wildcards.csr.pem' | openssl x509 -req -days 90 -copy_extensions copyall -sha384 -in '../cert/ugly/domain-multiple-wildcards.csr.pem' -signkey '../cert/ugly/private/domain-multiple-wildcards.key.pem' -passin 'file:../cert/ugly/private/domain-multiple-wildcards.key.pass.txt' -out '../cert/ugly/domain-multiple-wildcards.cert.pem' |



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
  And TP should have printed "Generating key-pair and CSR..."
  And TP should have run command `<csr_command>`
  And private key file `<path>/private/<name>.key.pem` should exist
  And key passphrase file `<path>/private/<name>.key.pass.txt` should exist
  And CSR file `<path>/<name>.csr.pem` should exist
  And CNs in CSR `<path>/<name>.csr.pem` and config `<path>/<name>.cert.conf` should match
  But self-signed X.509 certificate file `<path>/<name>.cert.pem` should NOT exist

  When I run `tp cert selfsign <path>/<name>.csr.pem`
  Then the command should succeed
  And TP should have printed "Signing CSR with it's own private key..."
  And TP should have run command `<selfsign_command>`
  And self-signed X.509 certificate file `<path>/<name>.cert.pem` should exist
  And CNs in certificate `<path>/<name>.cert.pem` and CSR `<path>/<name>.csr.pem` should match

  Examples:
    | path         | name                      | csr_command                                                                                                                                                                                                                                                                    | selfsign_command                                                                                                                                                                                                                                                                                                     |
    | ../cert/good | rsa-4096                  | openssl req -new -config '../cert/good/rsa-4096.cert.conf' -passout 'file:../cert/good/private/rsa-4096.key.pass.txt' -keyout '../cert/good/private/rsa-4096.key.pem' -out '../cert/good/rsa-4096.csr.pem'                                                                     | openssl x509 -req -days 90 -copy_extensions copyall -sha512 -in '../cert/good/rsa-4096.csr.pem' -signkey '../cert/good/private/rsa-4096.key.pem' -passin 'file:../cert/good/private/rsa-4096.key.pass.txt' -out '../cert/good/rsa-4096.cert.pem'                                                                     |
    | ../cert/good | ecdsa-256                 | openssl req -new -config '../cert/good/ecdsa-256.cert.conf' -newkey 'param:../cert/good/ecdsa-256.key.params.pem' -passout 'file:../cert/good/private/ecdsa-256.key.pass.txt' -keyout '../cert/good/private/ecdsa-256.key.pem' -out '../cert/good/ecdsa-256.csr.pem'           | openssl x509 -req -days 90 -copy_extensions copyall -sha384 -in '../cert/good/ecdsa-256.csr.pem' -signkey '../cert/good/private/ecdsa-256.key.pem' -passin 'file:../cert/good/private/ecdsa-256.key.pass.txt' -out '../cert/good/ecdsa-256.cert.pem'                                                                 |
    | ../cert/ugly | domain-multiple-wildcards | openssl req -new -config '../cert/ugly/domain-multiple-wildcards.cert.conf' -passout 'file:../cert/ugly/private/domain-multiple-wildcards.key.pass.txt' -keyout '../cert/ugly/private/domain-multiple-wildcards.key.pem' -out '../cert/ugly/domain-multiple-wildcards.csr.pem' | openssl x509 -req -days 90 -copy_extensions copyall -sha384 -in '../cert/ugly/domain-multiple-wildcards.csr.pem' -signkey '../cert/ugly/private/domain-multiple-wildcards.key.pem' -passin 'file:../cert/ugly/private/domain-multiple-wildcards.key.pass.txt' -out '../cert/ugly/domain-multiple-wildcards.cert.pem' |



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
  And TP should have printed "Generating key-pair and CSR..."
  And a nested command should have printed error "<error>"
  And config file `<path>/<name>.cert.conf` should exist
  And key passphrase file `<path>/private/<name>.key.pass.txt` should exist
  But private key file `<path>/private/<name>.key.pem` should NOT exist
  And CSR file `<path>/<name>.csr.pem` should NOT exist
  And self-signed X.509 certificate file `<path>/<name>.cert.pem` should NOT exist

  When I run `tp cert selfsign "<path>/<name>.cert.conf"`
  Then the command should fail
  And TP should have printed "Generating key-pair and CSR..."
  And a nested command should have printed error "<error>"
  And config file `<path>/<name>.cert.conf` should exist
  And key passphrase file `<path>/private/<name>.key.pass.txt` should exist
  But private key file `<path>/private/<name>.key.pem` should NOT exist
  And CSR file `<path>/<name>.csr.pem` should NOT exist
  And self-signed X.509 certificate file `<path>/<name>.cert.pem` should NOT exist

  Examples:
    | path        | name               | error                      |
    | ../cert/bad | rsa-short-key-404  | Error setting keysize      |
