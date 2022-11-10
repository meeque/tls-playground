# TLS Playground nginx Server

This TLS Playground component provides an nginx web-server setup that makes use of the [TLS Playground CA](../ca/). The nginx setup consists of multiple virtual hosts that demonstrate certain aspects of a TLS server:

* `server1` focuses on server-side TLS in a multi-domain scenario
* `server2` focuses on TLS with both server and client certificates



## Setup and Run

Both nginx virtual hosts come with a working out-of-the-box TLS configuration. However, this project does not ship with hardcoded server certificates. Thus you will first need to bootstrap the [TLS Playground CA](../ca/), then create appropriate server certificates. After CA bootstrapping, run the following commands in the root directory of the TLS Playground:

    ca/ca.sh request ca1 server-nginx/servers/server1/tls/server.config
    ca/ca.sh request ca1 server-nginx/servers/server2/tls/server.config
    
    cat ca/ca1/ca-cert.pem ca/ca2/ca-cert.pem > server-nginx/servers/server2/tls/trusted-clients-cas.pem

This will use the TLS certificate configuration that comes with TLS playground nginx server, and use `ca1` to generate appropriate keys and certificates. It will also create file `trusted-clients-cas.pem`, which contains the root certificates of both `ca1` and `ca2`.  Whenever these certificates expire, just rerun the above commands.

Once all this is in place, you can run the nginx server like so:

    nginx -p ./server-nginx/ -c nginx.conf

Again, this command must be issued from the root directory of the TLS Playground, that is the parent of this directory. If everything has worked, nginx will not emit any outputs on startup.



## Using the Playground Servers

Here's some suggestions on how you can use the preconfigured TLS Playground nginx virtual servers.



### Hostname Setup

The virtual servers of the TLS playground all run on the same IP (localhost) and port. In order to address them, it is recommended that you add the following to your `/etc/hosts` file:

    # TLS Playground hosts
    127.0.0.1       server1.tls-playground.localhost
    127.0.0.1       server1a.tls-playground.localhost
    127.0.0.1       server1b.tls-playground.localhost
    127.0.0.1       server1c.tls-playground.localhost
    127.0.0.1       foo.server1.tls-playground.localhost
    127.0.0.1       bar.server1.tls-playground.localhost
    127.0.0.1       foo.bar.server1.tls-playground.localhost
    127.0.0.1       server2.tls-playground.localhost

Since `server1` is the default virtual server, you can also access is via `localhost` from your machine.



### Accessing with Web-Browsers

You can access the TLS Playground nginx server at one of the above hosts. Use the `https` protocol and port `8443`. For example:

    https://localhost:8443/

Please be aware that your browser will issue a TLS warning at first. This is because the browser does not trust the private TLS Playground CA that has issued the server certificates. You can ask your browser to ignore the TLS Certificate warning and continue to the server. However, the browser will still show the connection as insecure. Also, it may not warn you about other TLS problems that may occur.

Instead, you can install the root certificate of TLS Playground `ca1` in your operating system or web browser and establish full trust. Most browsers (e.g. Chrome) take trusted root certificates from the underlying operating system configuration. You can install TLS Playground `ca1` there, but this will affect all software on your machine.

In contrast, the Firefox web-browser manages its own certificates, which makes it an ideal candidate for testing. To install the TLS Playground `ca1` root certificate there, do the following:

1. Open the Firefox *Certificate Manager* by going to *Preferences* >> *Privacy & Security* >> *View Certificates...*
2. Go to the *Authorities* tab, and click on *Import...*
3. Now select the root certificate of TLS Playground `ca1`. It is located at:<br>
`ca/ca1/ca-cert.pem`
4. Confirm that you want to trust this certificate for websites.

You can now find this certificate under in the *Authorities* list under *TLS Playground* / *PlayCA1*. Here you can review the details of the certificate, for example its validity period. You can also uninstall the certificate if you do not want to trust it any longer. (You should do so, once you stop using the TLS Playground!)



### Accessing with curl

CLI clients like `curl` typically rely on the trusted CA root certificates that are installed in the operating system. However, you can also specify a trust root as an argument. Here is how to securely request the TLS Playground nginx server with `curl`. Run this in the root directory of the TLS playground:

    curl --cacert ca/ca1/ca-cert.pem https://server1.tls-playground.localhost:8443/



## The Playground Virtual Servers

Here is additional information on using using the individual virtual servers in the TLS Playground.



### Using server1

TLS Playground `server1` demonstrates a multi-domain certificate setup including wildcards. See above for testing that either in a web-browser or with curl.

Also see the section on Hostname Setup for a variety of DNS names that you can use to access `server1`. Most of these hostnames are listed in the server certificate of `server1`. This is possible because `server1` makes use of the `Subject Alt Name` extension in its certificate. It also uses a wildcard entry for certain subdomains.

However, the server certificate of `server1` does not cover all of the hostnames from the Hostname Setup section. Try to find out which ones yield a certificate error!



### Using server2

TLS Playground `server2` demonstrates the use of client certificates. If you request the server without specifying a client certificate, it will respond with status 400 and an error page. You can try this with `curl`:

    curl --cacert ca/ca1/ca-cert.pem https://server2.tls-playground.localhost:8443/

In order to get a 200 response status from `server2`, your client will need to present a valid certificate that is signed by Playground `ca2`. To obtain and use such a certificate, see [TLS Playground Generic Client Support](../client-generic/).
