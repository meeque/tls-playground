# TLS Playground Demo Clients

This TLS Playground module provides demo clients that make use of TLS certificates.
This includes validation of server certificates and authentication with client certificates (mTLS).



## WIP Disclaimer

The demo clients are **work in progress**!
They cannot be controlled with the TP CLI yet.
And they are poorly documented.

That said, find some information on the existing demo clients here:

* [generic client](generic/README.md)
* [Java client](java/README.md)



## How to Configure TLS Clients

This section explains how to configure clients to trust server certificates that they would not trust by default.
This is useful for accessing [TP Demo Servers](../server/README.md) that are using certifcates that are self-signed, issued by a private CA, or issued by a non-production ACME server.

#### Configuring Web-Browsers

You can ask your browser to ignore the TLS Certificate warning and continue to the server.
However, the browser will still show the connection as insecure.
Also, it may not warn you about other TLS problems that may occur.

Instead, you can install the root certificate of TLS Playground `ca1` in your operating system or web browser and establish full trust.
Most browsers (e.g. Chrome) take trusted root certificates from the underlying operating system configuration.
You can install TLS Playground `ca1` there, but this will affect all software on your machine.

In contrast, the Firefox web-browser manages its own certificates, which makes it an ideal candidate for testing.
To install the TLS Playground `ca1` root certificate there, do the following:

1. Open the Firefox *Certificate Manager* by going to *Preferences* >> *Privacy & Security* >> *View Certificates...*
2. Go to the *Authorities* tab, and click on *Import...*
3. Now select the root certificate of TLS Playground `ca1`. It is located at:<br>
`ca/ca1/ca-cert.pem`
4. Confirm that you want to trust this certificate for websites.

You can now find this certificate under in the *Authorities* list under *TLS Playground* / *PlayCA1*.
Here you can review the details of the certificate, for example its validity period.
You can also uninstall the certificate if you do not want to trust it any longer.
(You should do so, once you stop using the TLS Playground!)

#### Configuring curl

CLI clients like `curl` typically rely on the trusted CA root certificates that are installed in the operating system.
However, you can also specify a trust root as an argument.
Here is how to securely request the TLS Playground nginx server with `curl`.
Run this in the root directory of the TLS playground:

```
curl --cacert ca/ca1/ca-cert.pem https://host1.tls-playground.localhost:8443/
```
