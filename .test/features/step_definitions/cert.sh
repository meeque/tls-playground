@Given a valid template file
  ls ../cert/good/rsa-4096.cert.conf.tmpl

@Given a valid OpenSSL certificate config file
  ls ../cert/good/rsa-4096.cert.conf

@Given a valid CSR
  ls ../cert/good/rsa-4096.csr.pem



@When I pass the template file to `tp cert init`
  tp cert init ../cert/good/rsa-4096.cert.conf.tmpl

@When I pass the config file to `tp cert request`
  tp cert request ../cert/good/rsa-4096.cert.conf

@When I pass the CSR file to `tp cert selfsign`
  tp cert selfsign ../cert/good/rsa-4096.csr.pem



@Then `tp` should generate a certificate config file next to the template file
  ls ../cert/good/rsa-4096.cert.conf

@Then `tp` should create a private key in a `private` directory next to the config file
  ls ../cert/good/private/rsa-4096.key.pem

@Then `tp` should create a key password file in a `private` directory next to the config file
  ls ../cert/good/private/rsa-4096.key.pass.txt

@Then `tp` should create a CSR next to the config file
  ls ../cert/good/rsa-4096.csr.pem

@Then `tp` should create a certificate next to the config file
  ls ../cert/good/rsa-4096.cert.pem