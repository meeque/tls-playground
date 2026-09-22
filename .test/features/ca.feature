Feature: ca
  Manage and use TP Demo Certificate Authorities (CAs)



Background:

  Given all TP CAs have been cleaned
  And all TP sample certificates have been cleaned



Scenario: When called without arguments, `tp ca` should print basic usage info

  When I run `tp ca`
  Then the command should fail
  And TP should print "No TP Demo CA command given."
  And TP should print "Try one of the following:"
  And a sub-command should print "init"
  And a sub-command should print "sign"
  And a sub-command should print "clean"
  And TP should print "Or, run 'tp ca --help' to learn more about these commands."



Scenario: `tp ca --help` should print help contents

  When I run `tp ca --help`
  Then the command should succeed
  And a sub-command should print "Summary:      Control TLS Playground Demo CAs"
  And a sub-command should print "Available Commands:"
  And a sub-command should print "Arguments:"
  And a sub-command should print "Global Options:"



Scenario Outline: Initialize CA `<ca>` and clean up afterwards

  Then CA config file `ca/<ca>/ca.conf` should exist
  And CA root config file `ca/<ca>/ca-root.cert.conf` should exist
  But CA root certificate file `ca/<ca>/ca-root.cert.pem` should NOT exist
  And CA private key file `ca/<ca>/private/ca-root.key.pem` should NOT exist
  And CA cert database file `ca/<ca>/db.txt` should NOT exist
  And CA serial file `ca/<ca>/serial` should NOT exist

  When I run `tp ca init <ca>`
  Then the command should succeed
  And TP should print "Creating scaffolding for CA '<ca>'"
  And TP should print "Preparing root certificate for CA '<ca>'"
  And CA root certificate file `ca/<ca>/ca-root.cert.pem` should exist
  And CA root CSR file `ca/<ca>/ca-root.csr.pem` should exist
  And CA private key file `ca/<ca>/private/ca-root.key.pem` should exist
  And CA private key passphrase file `ca/<ca>/private/ca-root.key.pass.txt` should exist
  And CA cert database file `ca/<ca>/db.txt` should exist
  And CA serial file `ca/<ca>/serial` should exist
  And 0 files in `ca/<ca>/archive` should match wildcard pattern `*.pem`

  When I run `tp ca clean <ca>`
  Then the command should succeed
  And TP should print "Cleaning transient files of CA '<ca>'"
  And CA root certificate file `ca/<ca>/ca-root.cert.pem` should NOT exist
  And CA private key file `ca/<ca>/private/ca-root.key.pem` should NOT exist
  And CA cert database file `ca/<ca>/db.txt` should NOT exist
  And CA serial file `ca/<ca>/serial` should NOT exist
  But CA config file `ca/<ca>/ca.conf` should exist
  And CA root config file `ca/<ca>/ca-root.cert.conf` should exist

  Examples:
    | ca         |
    | ca4all     |
    | ca4clients |
    | ca4servers |



Scenario: Initialize all TP CAs at once

  When I run `tp ca init`
  Then the command should succeed
  And TP should print "No CA name specified. Proceeding to initialize all CAs..."
  And CA root certificate file `ca/ca4all/ca-root.cert.pem` should exist
  And CA root certificate file `ca/ca4servers/ca-root.cert.pem` should exist
  And CA root certificate file `ca/ca4clients/ca-root.cert.pem` should exist



Scenario Outline: Sign certificate `cert/good/<name>.cert.pem` with CA `<ca>`

  When I run `tp ca init <ca>`
  Then the command should succeed
  And CA root certificate file `ca/<ca>/ca-root.cert.pem` should exist

  When I run `tp cert init cert/good/<name>.cert.conf.tmpl`
  Then the command should succeed
  And config file `cert/good/<name>.cert.conf` should exist

  When I run `tp ca sign <ca> cert/good/<name>.cert.conf`
  Then the command should succeed
  And TP should print "Generating CSR for the new certificate..."
  And TP should print "Signing CSR from 'cert/good/<name>.csr.pem' with CA <ca>"
  And private key file `cert/good/private/<name>.key.pem` should exist
  And CSR file `cert/good/<name>.csr.pem` should exist
  And CA-signed certificate file `cert/good/<name>.cert.pem` should exist
  And CA-signed cert chain file `cert/good/<name>.chain.pem` should exist
  And CA-signed cert full-chain file `cert/good/<name>.fullchain.pem` should exist
  And 1 files in `ca/<ca>/archive` should match wildcard pattern `*.cert.pem`
  And 1 files in `ca/<ca>/archive` should match wildcard pattern `*.chain.pem`
  And 1 files in `ca/<ca>/archive` should match wildcard pattern `*.fullchain.pem`
  And CNs in certificate `cert/good/<name>.cert.pem` and CSR `cert/good/<name>.csr.pem` should match

  Examples:
    | ca         | name      |
    | ca4all     | rsa-4096  |
    | ca4clients | ecdsa-256 |
    | ca4servers | rsa-4096  |



Scenario: Fail signing when no CA is specified

  When I run `tp ca sign`
  Then the command should fail
  And TP should print "No CA name specified. Specify the CA to sign with!"
  And TP should print "Try one of the following:"
  And a sub-command should print "ca4all"
  And a sub-command should print "ca4servers"
  And a sub-command should print "ca4clients"



Scenario: Fail signing with a non-existent CA

  When I run `tp ca sign not-a-ca cert/good/rsa-4096.cert.conf.tmpl`
  Then the command should fail
  And TP should print "CA with name 'not-a-ca' does not exist!"
  And TP should print "Try one of the following instead:"
  And a sub-command should print "ca4all"
  And a sub-command should print "ca4servers"
  And a sub-command should print "ca4clients"



Scenario: Fail signing when CA is not initialized

  When I run `tp cert init cert/good/rsa-4096.cert.conf.tmpl`
  Then the command should succeed

  When I run `tp ca sign ca4servers cert/good/rsa-4096.cert.conf`
  Then the command should fail
  And TP should print "Could not find root certificate of CA ca4servers"
  And TP should print "Initialize the CA first!"
