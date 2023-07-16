# TLS Playground Demo Servers

This TLS Playground component provides demo web-servers that makes use of
TLS server certificates.



## `server` Commands Summary

```
Summary:    Control TLS Playground Demo Servers

Usage:      tp [<global options>] server <command> [<server>] [<options>]

Available commands:

  init      Initialize the given TP demo <server>:
            Generate config files from templates, request and install necessary
            certificates and private keys, and run server-specific init hooks.
            Certificates will be based on the certificate configurations that
            are part of the demo <server>. By default, certificates will be
            self-signed, but see --ca and --acme options for alternatives.
            When <server> is omitted, initialize all TP demo servers.

  run       Run the given TP demo <server> in the foreground.
            The <server> argument is mandatory here. You'll need to initialize
            the <server> beforehand, using the init command.
            TP demo servers are designed to be run one at a time, mostly because
            they all listen to the same port by default. See env-var
            TP_SERVER_HTTPS_PORT.

  start     Start the given TP demo <server> in the background.
            See run command for details.

  reload    Reload configuration of the given TP demo <server> running in the
            background. See start command.

  stop      Stop the given TP demo <server> running in the background. See start
            command.

  clean     Clean up the given TP demo <server>:
            Delete generated config files, transient files, and associated
            certificates and private keys. Note that copies of the latter may
            survive elsewhere, e.g. in the cert DB of a TP 'ca' or in an ACME
            archive directory.
            When <server> is omitted, clean up all TP demo servers.

Arguments:

  <server>  Name of a TP demo server.
            Each TP demo server is represented by a sub-directory of
            ${tp_base_dir}/server/.
            The name of this sub-directory is also the name of the server.

Options:

  -c[<ca>], --ca[=<ca>]
            When running the init command, request certificates from a TP CA,
            instead of using self-signed certificates.
            This is equivalent to running 'tp ca sign <ca>' for all cert
            configurations of the demo server. If the <ca> is omitted the
            default TP CA will be used.

  -a, --acme
            When running the init command, request certificates from a CA using
            'certbot' and the ACME protocol, instead of using self-signed
            certificates.
            This is equivalent to running 'tp acme sign' for all cert
            configurations of the demo server. See the sign command for details
            and additional options.

Environment:

  Set ${TP_SERVER_DOMAIN}, ${TP_SERVER_LISTEN_ADDRESS}, and ${TP_SERVER_HTTPS_PORT}
  to configure the TP demo servers.

  Run 'tp --help env' to learn more about these env-vars.
```



## Server Usage

The nginx setup consists of multiple virtual hosts that demonstrate certain aspects of a TLS server:

* `server0` focuses on a simple single-domain scenario, but can be upgraded to use Let's Encrypt certificates obtained with ACME
* `server1` focuses on server-side TLS in a multi-domain scenario
* `server2` focuses on TLS with both server and client certificates



## Setup and Run

All nginx virtual hosts come with a working out-of-the-box TLS configuration. However, this project does not ship with hardcoded server certificates. Thus you will first need to bootstrap the [TLS Playground CA](../ca/), then create appropriate server certificates. After CA bootstrapping, run the following commands in the root directory of the TLS Playground:

    ca/ca.sh request ca1 server-nginx/servers/server0/tls/server.config
    ca/ca.sh request ca1 server-nginx/servers/server1/tls/server.config
    ca/ca.sh request ca1 server-nginx/servers/server2/tls/server.config
    
    cat ca/ca1/ca-cert.pem ca/ca2/ca-cert.pem > server-nginx/servers/server2/tls/trusted-clients-cas.pem

This will use the TLS certificate configuration that comes with TLS playground nginx server, and use `ca1` to generate appropriate keys and certificates. It will also create file `trusted-clients-cas.pem`, which contains the root certificates of both `ca1` and `ca2`.  Whenever these certificates expire, just rerun the above commands.

Once all this is in place, you can run the nginx server like so:

    nginx -p ./server-nginx/ -c nginx.conf

Again, this command must be issued from the root directory of the TLS Playground, that is the parent of this directory. If everything has worked, nginx will not emit any outputs on startup.



## Using the Playground Servers

Here's some suggestions on how you can use the pre-configured TLS Playground nginx virtual servers.



### Hostname Setup

The virtual servers of the TLS Playground all run on the same IP (localhost) and port. In order to address them, it is recommended that you add the following to your `/etc/hosts` file:

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
