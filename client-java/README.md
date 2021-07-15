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



## PKIX Certificate Revocation Checks (Programmatically)

By default, Java TLS clients using a standard `SSLContext` do not seem to perform certificate revocation checks according to the PKIX standard. This may differ among JVM versions and vendors though.

This Java client supports configuration option `--tls.check-revocation=true` to explicitly enable certificate revocation checking using OCSP.

Usage examples:
```
# HTTPS request to a server with a revoked certificate.
# Using default TLS configuration.
# This request is expected to succeed, since the default configuration does not perform revocation checks.
java -jar 'target/tls-playground-client-0.0.1-SNAPSHOT.jar' 'https://revoked.badssl.com/'

# HTTP request to a server with a revoked certificate.
# Using a custom Java `SSLContext` with PKIX revocation checks.
# This is expected to fail and print a Java Exception that indicates that the certificate has been revoked.
java -jar 'target/tls-playground-client-0.0.1-SNAPSHOT.jar' --tls.check-revocation='true' 'https://revoked.badssl.com/'
```



## PKIX Certificate Revocation Checks (via JVM Configuration)

Alternatively, some JSSE providers can be configured to perform revocation checks. This may be provider-dependent, but it seems to work with the default provider configuration comming with most JDK flavors.

Certificate revocation checks with OCSP can be configured via a combination of *Java System Properties* and *Java Security Properties*. The latter can be set programmatically, or by an additional configuration properties file, e.g. [this one](config/jvm/java.security).

The recommended configuration for OCSP is:
* System property:
  ```
  com.sun.net.ssl.checkRevocation=true
  ```
* Security property:
  ```
  ocsp.enable=true
  ```

Usage example:
```
# HTTP request to a server with a revoked certificate.
# Using a default Java `SSLContext` with appropriate Java configuration properties.
# This is expected to fail and print a Java Exception that indicates that the certificate has been revoked.
java -Dcom.sun.net.ssl.checkRevocation=true -Djava.security.properties=config/jvm/java.security -jar 'target/tls-playground-client-0.0.1-SNAPSHOT.jar' 'https://revoked.badssl.com/'
```



## Client Certificates

**TODO** Document how to use the `--tls.client-cert` and `--tls.client-key` configuration options.
