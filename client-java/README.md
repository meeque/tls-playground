# TLS Playground Java Client

This TLS Playground component helps you with configuring Java TLS clients. This includes configuration of client certificates, which is particularly useful when accessing [TLS Playground nginx server2](../server-nginx/).



## General Configuration

This client supports making HTTPS GET requests to arbitrary URLs. Specify one or more URLs in non-option arguments.

Use option arguments (those in the form `--foo=bar`) to control the TLS configuration. The client is implemented in Spring Boot – for supported configuration options see the [TlsProperties](src/main/java/com/sap/cx/jester/tlsplayground/client/tls/TlsProperties.java) file.

Usage examples:

```
# HTTPS request with default TLS configuration
java -jar 'target/tls-playground-client-0.0.1-SNAPSHOT.jar' 'https://en.wikipedia.org/' 

# 2 HTTPS requests with default TLS configuration
java -jar 'target/tls-playground-client-0.0.1-SNAPSHOT.jar' 'https://badssl.com/' 'https://en.wikipedia.org/wiki/Transport_Layer_Security'
```


## PKIX Certificate Revocation Checks

By default, Java TLS clients using a standard `SSLContext` do not seem to perform certificate revocation checks according to the PKIX standard. This may differ among JVM versions and vendors though.

This Java client supports configuration option `--tls.check-revocation=true` to explicitly enable certificate revocation checking using OCSP.

**XXX** Currently, `--tls.check-revocation=true` will only work when used in conjunction with configuration option `--tls.trusted-certs` which takes a list of files that contain trusted CA certificates in DER format. You will have to manage those files yourself, e.g. by exporting them from your OS key manager, web-browser, or Java trust store.

Usage examples:
```
# HTTPS request to a server with a revoked certificate.
# Using default TLS configuration.
# This request is expected to succeed, since the default configuration does not perform revocation checks.
java -jar 'target/tls-playground-client-0.0.1-SNAPSHOT.jar' 'https://revoked.badssl.com/'

# HTTP request to a server with a revoked certificate.
# Using a custom list of trusted CA certificates (with a single entry) and a Java `SSLContext` with PKIX revocation checks.
# This is expected to fail and print a Java Exception that indicates that the certificate has been revoked.
java -jar 'target/tls-playground-client-0.0.1-SNAPSHOT.jar' --tls.trusted-certs='DigiCert Global Root CA.der' --tls.check-revocation='true' 'https://revoked.badssl.com/'
```


## Client Certificates

**TODO** Document how to use the `--tls.client-cert` and `--tls.client-key` configuration options.
