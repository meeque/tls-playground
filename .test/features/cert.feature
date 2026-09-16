Feature: cert
  Manage X.509 certificates



Scenario Outline: Create a certificate config file from template
  Given template file `<template>`
  When I run `tp cert init <template>`
  Then `tp` should generate config file `<config>`

  Examples:
    | template                              | config                           |
    | ../cert/good/rsa-4096.cert.conf.tmpl  | ../cert/good/rsa-4096.cert.conf  |
    | ../cert/good/ecdsa-256.cert.conf.tmpl | ../cert/good/ecdsa-256.cert.conf |



Scenario Outline: Create a certifcate signing request (CSR)
  Given OpenSSL certificate config file `<config>`
  When I run `tp cert request <config>`
  Then `tp` should generate private key file `<key>`
  And `tp` should generate key passphrase file `<pass>`
  And `tp` should generate CSR file `<csr>`
  And CN in CSR file `<csr>` should match CN in certificate config file `<config>`

  Examples:
    | config                           | key                                    | pass                                        | csr                            |
    | ../cert/good/rsa-4096.cert.conf  | ../cert/good/private/rsa-4096.key.pem  | ../cert/good/private/rsa-4096.key.pass.txt  | ../cert/good/rsa-4096.csr.pem  |
    | ../cert/good/ecdsa-256.cert.conf | ../cert/good/private/ecdsa-256.key.pem | ../cert/good/private/ecdsa-256.key.pass.txt | ../cert/good/ecdsa-256.csr.pem |



Scenario Outline: Create a self-signed certificate
  Given CSR file `<csr>`
  And private key file `<key>`
  And key passphrase file `<pass>`
  When I run `tp cert selfsign <csr>`
  Then `tp` should generate self-signed X.509 certificate file `<cert>`
  And CN in certificate file `<cert>` should match CN in CSR file `<csr>`

  Examples:
    | key                                    | pass                                        | csr                            | cert                            |
    | ../cert/good/private/rsa-4096.key.pem  | ../cert/good/private/rsa-4096.key.pass.txt  | ../cert/good/rsa-4096.csr.pem  | ../cert/good/rsa-4096.cert.pem  |
    | ../cert/good/private/ecdsa-256.key.pem | ../cert/good/private/ecdsa-256.key.pass.txt | ../cert/good/ecdsa-256.csr.pem | ../cert/good/ecdsa-256.cert.pem |
