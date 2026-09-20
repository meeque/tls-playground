Feature: cert
  Manage X.509 certificates



Background:

  Given all sample certificates have been cleaned



Scenario: When called without arguments, `tp cert` should print basic usage info

  When I run `tp cert`
  Then the command should fail
  And TP should print "No TP Certificate Utilities command given."
  And TP should print "Try one of the following:"
  And a sub-command should print "init"
  And a sub-command should print "request"
  And a sub-command should print "selfsign"
  And a sub-command should print "clean"
  And TP should print "Or, run 'tp cert --help' to learn more about these commands."



Scenario: `tp cert --help` should print help contents

  When I run `tp cert --help`
  Then the command should succeed
  And a sub-command should print "Summary:   TLS Playground Certificate Utilities"
  And a sub-command should print "Available Commands:"
  And a sub-command should print "Arguments:"
  And a sub-command should print "Global Options:"
  And a sub-command should print "Environment:"



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
  And TP should print "Generating key-pair and CSR..."
  And TP should run command `<csr_command>`
  And TP should print "Signing CSR with it's own private key..."
  And TP should run command `<selfsign_command>`
  And private key file `<path>/private/<name>.key.pem` should exist
  And key passphrase file `<path>/private/<name>.key.pass.txt` should exist
  And CSR file `<path>/<name>.csr.pem` should exist
  And self-signed X.509 certificate file `<path>/<name>.cert.pem` should exist
  And CNs in CSR `<path>/<name>.csr.pem` and config `<path>/<name>.cert.conf` should match
  And CNs in certificate `<path>/<name>.cert.pem` and CSR `<path>/<name>.csr.pem` should match

  When I run `tp cert verify <path>/<name>.cert.pem`
  Then the command should succeed
  And TP should print "Verified"

  When I run `tp cert verify <path>/<name>.csr.pem`
  Then the command should succeed
  And TP should print "Verified"

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
    | ../cert/bad  | rsa-short-key-1337        | openssl req -new -config '../cert/bad/rsa-short-key-1337.cert.conf' -passout 'file:../cert/bad/private/rsa-short-key-1337.key.pass.txt' -keyout '../cert/bad/private/rsa-short-key-1337.key.pem' -out '../cert/bad/rsa-short-key-1337.csr.pem'                                | openssl x509 -req -days 90 -copy_extensions copyall -sha384 -in '../cert/bad/rsa-short-key-1337.csr.pem' -signkey '../cert/bad/private/rsa-short-key-1337.key.pem' -passin 'file:../cert/bad/private/rsa-short-key-1337.key.pass.txt' -out '../cert/bad/rsa-short-key-1337.cert.pem'                                  |



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
  And TP should print "Generating key-pair and CSR..."
  And TP should run command `<csr_command>`
  And private key file `<path>/private/<name>.key.pem` should exist
  And key passphrase file `<path>/private/<name>.key.pass.txt` should exist
  And CSR file `<path>/<name>.csr.pem` should exist
  And CNs in CSR `<path>/<name>.csr.pem` and config `<path>/<name>.cert.conf` should match
  But self-signed X.509 certificate file `<path>/<name>.cert.pem` should NOT exist

  When I run `tp cert verify <path>/<name>.csr.pem`
  Then the command should succeed
  And TP should print "Verified"

  When I run `tp cert selfsign <path>/<name>.csr.pem`
  Then the command should succeed
  And TP should print "Signing CSR with it's own private key..."
  And TP should run command `<selfsign_command>`
  And self-signed X.509 certificate file `<path>/<name>.cert.pem` should exist
  And CNs in certificate `<path>/<name>.cert.pem` and CSR `<path>/<name>.csr.pem` should match

  When I run `tp cert verify <path>/<name>.cert.pem`
  Then the command should succeed
  And TP should print "Verified"

  Examples:
    | path         | name                      | csr_command                                                                                                                                                                                                                                                                    | selfsign_command                                                                                                                                                                                                                                                                                                     |
    | ../cert/good | rsa-4096                  | openssl req -new -config '../cert/good/rsa-4096.cert.conf' -passout 'file:../cert/good/private/rsa-4096.key.pass.txt' -keyout '../cert/good/private/rsa-4096.key.pem' -out '../cert/good/rsa-4096.csr.pem'                                                                     | openssl x509 -req -days 90 -copy_extensions copyall -sha512 -in '../cert/good/rsa-4096.csr.pem' -signkey '../cert/good/private/rsa-4096.key.pem' -passin 'file:../cert/good/private/rsa-4096.key.pass.txt' -out '../cert/good/rsa-4096.cert.pem'                                                                     |
    | ../cert/good | ecdsa-256                 | openssl req -new -config '../cert/good/ecdsa-256.cert.conf' -newkey 'param:../cert/good/ecdsa-256.key.params.pem' -passout 'file:../cert/good/private/ecdsa-256.key.pass.txt' -keyout '../cert/good/private/ecdsa-256.key.pem' -out '../cert/good/ecdsa-256.csr.pem'           | openssl x509 -req -days 90 -copy_extensions copyall -sha384 -in '../cert/good/ecdsa-256.csr.pem' -signkey '../cert/good/private/ecdsa-256.key.pem' -passin 'file:../cert/good/private/ecdsa-256.key.pass.txt' -out '../cert/good/ecdsa-256.cert.pem'                                                                 |
    | ../cert/ugly | domain-multiple-wildcards | openssl req -new -config '../cert/ugly/domain-multiple-wildcards.cert.conf' -passout 'file:../cert/ugly/private/domain-multiple-wildcards.key.pass.txt' -keyout '../cert/ugly/private/domain-multiple-wildcards.key.pem' -out '../cert/ugly/domain-multiple-wildcards.csr.pem' | openssl x509 -req -days 90 -copy_extensions copyall -sha384 -in '../cert/ugly/domain-multiple-wildcards.csr.pem' -signkey '../cert/ugly/private/domain-multiple-wildcards.key.pem' -passin 'file:../cert/ugly/private/domain-multiple-wildcards.key.pass.txt' -out '../cert/ugly/domain-multiple-wildcards.cert.pem' |
    | ../cert/bad  | rsa-short-key-1337        | openssl req -new -config '../cert/bad/rsa-short-key-1337.cert.conf' -passout 'file:../cert/bad/private/rsa-short-key-1337.key.pass.txt' -keyout '../cert/bad/private/rsa-short-key-1337.key.pem' -out '../cert/bad/rsa-short-key-1337.csr.pem'                                | openssl x509 -req -days 90 -copy_extensions copyall -sha384 -in '../cert/bad/rsa-short-key-1337.csr.pem' -signkey '../cert/bad/private/rsa-short-key-1337.key.pem' -passin 'file:../cert/bad/private/rsa-short-key-1337.key.pass.txt' -out '../cert/bad/rsa-short-key-1337.cert.pem'                                  |



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
  And TP should print "Generating key-pair and CSR..."
  And a sub-command should print error "<error>"
  And config file `<path>/<name>.cert.conf` should exist
  And key passphrase file `<path>/private/<name>.key.pass.txt` should exist
  But private key file `<path>/private/<name>.key.pem` should NOT exist
  And CSR file `<path>/<name>.csr.pem` should NOT exist
  And self-signed X.509 certificate file `<path>/<name>.cert.pem` should NOT exist

  When I run `tp cert selfsign "<path>/<name>.cert.conf"`
  Then the command should fail
  And TP should print "Generating key-pair and CSR..."
  And a sub-command should print error "<error>"
  And config file `<path>/<name>.cert.conf` should exist
  And key passphrase file `<path>/private/<name>.key.pass.txt` should exist
  But private key file `<path>/private/<name>.key.pem` should NOT exist
  And CSR file `<path>/<name>.csr.pem` should NOT exist
  And self-signed X.509 certificate file `<path>/<name>.cert.pem` should NOT exist

  Examples:
    | path        | name               | error                      |
    | ../cert/bad | rsa-short-key-404  | Error setting keysize      |



Scenario Outline: Fail verifying `<path>/<name>` after regenerating its private key

  When I run `tp cert init "<path>/<name>.cert.conf.tmpl"`
  Then the command should succeed

  When I run `tp cert selfsign <path>/<name>.cert.conf`
  Then the command should succeed
  And private key file `<path>/private/<name>.key.pem` should exist
  And CSR file `<path>/<name>.csr.pem` should exist
  And self-signed X.509 certificate file `<path>/<name>.cert.pem` should exist

  When I run `tp cert verify <path>/<name>.cert.pem`
  Then the command should succeed
  And TP should print "Verified"

  When I run `tp cert verify <path>/<name>.csr.pem`
  Then the command should succeed
  And TP should print "Verified"

  When I run `tp cert key <path>/<name>.cert.conf`
  Then the command should succeed
  And TP should print "New private key"

  When I run `tp cert verify <path>/<name>.cert.pem`
  Then the command should fail
  And TP should print "does NOT match"

  When I run `tp cert verify <path>/<name>.csr.pem`
  Then the command should fail
  And TP should print "does NOT match"

  Examples:
    | path         | name      |
    | ../cert/good | rsa-4096  |
    | ../cert/good | ecdsa-256 |



Scenario Outline: Generate self-signed certificates all configs in `<dir>` and clean up afterwards

  Then 0 files in `<dir>` should match wildcard pattern `*.cert.conf`
  And 0 files in `<dir>` should match wildcard pattern `*.key.pass.txt`
  And 0 files in `<dir>` should match wildcard pattern `*.pem`

  When I run `tp cert init "<dir>"`
  Then the command should succeed
  And TP should print "Proceeding to init all certificates in '<dir>'..."
  And <count> files in `<dir>` should match wildcard pattern `*.cert.conf`
  But 0 files in `<dir>` should match wildcard pattern `*.key.pass.txt`
  And 0 files in `<dir>` should match wildcard pattern `*.pem`

  When I run `tp cert selfsign "<dir>"`
  Then the command should succeed
  And TP should print "Proceeding to selfsign all certificates in '<dir>'..."


  And <count> files in `<dir>` should match wildcard pattern `*.cert.conf`
  And <count> files in `<dir>` should match wildcard pattern `*.key.pass.txt`
  And <count> files in `<dir>` should match wildcard pattern `*.key.pem`
  And <count> files in `<dir>` should match wildcard pattern `*.csr.pem`
  And <count> files in `<dir>` should match wildcard pattern `*.cert.pem`

  When I run `tp cert clean "<dir>"`
  Then the command should succeed
  And TP should print "Proceeding to clean all certificates in '<dir>'..."
  And 0 files in `<dir>` should match wildcard pattern `*.cert.conf`
  And 0 files in `<dir>` should match wildcard pattern `*.key.pass.txt`
  And 0 files in `<dir>` should match wildcard pattern `*.pem`

  Examples:
    | dir           | count |
    | ../cert/good/ | 2     |
