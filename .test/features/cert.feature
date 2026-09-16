Feature: cert
  Manage X.509 certificates

Scenario: Generate a certificate config file from template
  Given a valid template file
  When I pass the template file to `tp cert init`
  Then `tp` should generate a certificate config file next to the template file

Scenario: Create a certifcate signing request (CSR)
  Given a valid OpenSSL certificate config file
  When I pass the config file to `tp cert request`
  Then `tp` should create a private key in a `private` directory next to the config file
  And `tp` should create a key password file in a `private` directory next to the config file
  And `tp` should create a CSR next to the config file

Scenario: Create a self-signed certificate
  Given a valid CSR
  When I pass the CSR file to `tp cert selfsign`
  Then `tp` should create a private key in a `private` directory next to the config file
  And `tp` should create a key password file in a `private` directory next to the config file
  And `tp` should create a certificate next to the config file
