Feature: cert
  Manage X.509 certificates



Scenario Outline: Create a certificate config file from template
  Given template file `<file>.cert.conf.tmpl`
  When I run `tp cert init "<file>.cert.conf.tmpl"`
  Then the command should succeed
  And `tp` should generate config file `<file>.cert.conf`

  Examples:
    | file                   |
    | ../cert/good/rsa-4096  |
    | ../cert/good/ecdsa-256 |



Scenario Outline: Create a certifcate signing request (CSR)
  Given OpenSSL certificate config file `<file>.cert.conf`
  When I run `tp cert request <file>.cert.conf`
  Then the command should succeed
  And `tp` should generate private key file `<private>.key.pem`
  And `tp` should generate key passphrase file `<private>.key.pass.txt`
  And `tp` should generate CSR file `<file>.csr.pem`
  And CN in CSR file `<file>.csr.pem` should match CN in certificate config file `<file>.cert.conf`

  Examples:
    | file                   | private                        |
    | ../cert/good/rsa-4096  | ../cert/good/private/rsa-4096  |
    | ../cert/good/ecdsa-256 | ../cert/good/private/ecdsa-256 |

Scenario Outline: Create a self-signed certificate
  Given CSR file `<file>.csr.pem`
  And private key file `<private>.key.pem`
  And key passphrase file `<private>.key.pass.txt`
  When I run `tp cert selfsign <file>.csr.pem`
  Then the command should succeed
  And `tp` should generate self-signed X.509 certificate file `<file>.cert.pem`
  And CN in certificate file `<file>.cert.pem` should match CN in CSR file `<file>.csr.pem`

  Examples:
    | file                   | private                        |
    | ../cert/good/rsa-4096  | ../cert/good/private/rsa-4096  |
    | ../cert/good/ecdsa-256 | ../cert/good/private/ecdsa-256 |
