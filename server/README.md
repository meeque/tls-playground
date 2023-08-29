# TLS Playground Demo Servers

This TLS Playground module provides demo web-servers that make use of TLS server certificates.
The TP demo servers make use of X.509 certificates created with other TP modules, such as [TP Certificate Utilities](../cert/README.md), [TP Demo CAs](../ca/README.md), or [TP ACME Utilities](../acme/README.md).
If you are not interested into too many details, the demo servers may be the best corner of this TLS Playground.
Where all the cool kids hang out;)

Currently, there are two TP demo servers, both based on [nginx](https://nginx.org/):

* `nginx-simple` is simple server with a single virtual host (and therefore a single server certificate).
* `nginx-complex` is a more complex server with multiple virtual hosts, one of which also checks client certificates.

The TP Demo Servers can be fully controlled through the `tp server` command of the TP CLI, but they make heavy use of other TP commands under the hood.
Therefore, you'll the same detailed outputs, in particular when invoking interesting CLI tools, like [OpenSSL](https://www.openssl.org/) or [Certbot](https://certbot.eff.org/).



## Demo Servers Usage

You can use the TP demo servers either locally or on an Internet-facing host, ideally a host with a public DNS record.
The TP Demo Servers use very little server-side web application logic, no client-side JavaScript code, and no cookies either.
They do not manage any assets whose confidentiality, integrity, or availability needs to be protected, except for their X.509 certificates and the respective private keys.
Nevertheless, when exposing TP Demo Servers to the Internet, it is recommended to run them on a non-production host (or at least on in an isolated Docker container).
It is also recommended to use the TP Demo Servers on a dedicated, non-production DNS domain (though a sub-domain should do).

### Initializing the Demo Servers

Before you can use a TP demo server, you need to initialize them.
Like other TP initialization commands, this will create the necessary directory structures and create config files from templates.
Unlike most other TP initialization commands, this will also create all certificates that are necessary for running the demo server.
These certificates will be based on the OpenSSL CSR config files that are part of the demo server configuration.

All TP demo servers can be configured with the `${TP_SERVER_DOMAIN}`, `${TP_SERVER_LISTEN_ADDRESS}`, and `${TP_SERVER_HTTPS_PORT}` environment variables.
Run `tp --help env` to learn more about these env-vars and their defaults.
Then run the following command to initialize a TP demo server:

```
tp server init nginx-simple
```

The above example initializes the demo server named `nginx-simple`, another option would be `nginx-complex`.
You can also omit the server name in the above command to initialize all TP demo servers at once.

Moreover, you can chose what flavor of certificates to use.
TP demo servers offer these flavors, each based on a specific TP module:

| Certificate Flavor  | Init Option | Related TP Module                          | Prerequisites                                                         |
| ------------------- | ----------- | ------------------------------------------ | --------------------------------------------------------------------- |
| Self-Signed         | *none*      | [Certificate Utilities](../cert/README.md) | none                                                                  |
| Built-In Private CA | `--ca`      | [Demo CAs](../ca/README.md)                | configure and initialize the demo CA                                  |
| ACME CA             | `--acme`    | [ACME Utilities](../acme/README.md)        | configure and initialize the ACME module, start the challenges server |

In the earlier example, we didn't use any initialization option, which means that the demo server would be initialized with self-signed server certificates.
The `--ca` option can be used together with the CA name to use, but this is optional.
For example, if you wish to initialize the TP demo server with the TP demo CA named `ca4all`run this command:

```
tp server init --ca=ca4all nginx-simple
```

### Running the Demo Servers

While you can initialize all TP demo servers with a single command, you can only run one of them at a time.
This is because the demo servers are all designed to listen to the same IP port, as configured with `${TP_SERVER_HTTPS_PORT}`.

To run a demo server in the foreground, use the `run` command:

```
tp server run nginx-simple
```

Running in foreground can help you see any error messages and other outputs from the server.
On the other hand, it will block the terminal where you've started the server.
To stop the server again, press `Ctrl+C`.

Alternatively, you can run a demo server in the background, using the `start`, `stop`, and `reload` commands.
See the TP Server Commands Reference below for details.

Note that the Challenges Server of the [ACME Utilities](../acme/README.md) module support `run`, `start`, `stop`, and `reload` commands that work in analogy to the ones described here.

### Accessing the Demo Servers

Once you have started a TP demo server, you can access it with an arbitrary HTTPS client, such as a web-browser or [cURL](https://curl.se/).
You can access the demo server either through its IP address or through its host name (see next section for the latter).
When using the default values of `${TP_SERVER_DOMAIN}`, `${TP_SERVER_LISTEN_ADDRESS}`, and `${TP_SERVER_HTTPS_PORT}`, you can access either demo server at the following URL:

```
https://localhost:8443/
```

This URL only works for access from the same host where the demo server is running.
To access from a different host, you will need to replace `localhost` with the IP-address or host name where the demo server is running.



### Host Name Configuration for the Demo Servers

The TP demo servers are configured to handle all HTTPS traffic, regardless of the `Host` header in the HTTPS request.
Or, more precisely, regardless of the [Server Name Indication (SNI)](https://datatracker.ietf.org/doc/html/rfc6066#page-6) extension seen during the TLS handshake.

In fact, demo server `nginx-simple` is entirely agnostic to the requested host name.
Demo server `nginx-complex` on the other hand, support multiple virtual hosts.
It will dispatch requests to the virtual host that is configured to handle requests for the host name specified through SNI.

In order to make full use of the `nginx-complex` demo server you will need to some form of host name configuration.
This will bind the relevant host names to the IP address where you're running the demo server.

Then running the demo servers on `localhost` (which is the default value of `${TP_SERVER_DOMAIN}`) you can simply add entries to your local `/etc/hosts` file.
The following entries are recommended:

```
127.0.0.1    tls-playground.localhost
127.0.0.1    host1.tls-playground.localhost
127.0.0.1    host1a.tls-playground.localhost
127.0.0.1    host1b.tls-playground.localhost
127.0.0.1    host1c.tls-playground.localhost
127.0.0.1    sub.host1.tls-playground.localhost
127.0.0.1    host2.tls-playground.localhost
```

Obviously, this only works when accessing the TP demo servers with clients running on the same host.

When running TP on an Internet-facing host, you can set up public DNS records for the supported virtual hosts instead.
Simply replace all occurrences of `localhost` from above `/etc/hosts` file with the name of your own DNS domain.
Then add the resulting host names to your DNS configuration and point their `A`-records (or `AAAA`-records) to the public IP address where you're running TP demo servers.

Alternatively, you can add wild-card entries for all of the above host names to your DNS configuration.
For example, when you configure your domain through a zone file, add the following entries, but replace `192.0.2.0` with the public IP address of your server:

```
tls-playground      IN    A    192.0.2.0
*.tls-playground    IN    A    192.0.2.0
```

Once your DNS configuration is in place, you should set the `${TP_SERVER_DOMAIN}` env-var to your domain, then reinitialize and restart the server as described in previous sections.
Note that the demo servers' host name configuration will always prepend the `tls-playground` sub-domain to the configured `${TP_SERVER_DOMAIN}`.
Assuming you've set `${TP_SERVER_DOMAIN}` to `example.net`, you will need DNS records for `tls-playground.example.net` and its sub-domains.

If you also set `${TP_SERVER_HTTPS_PORT}` to the HTTP default port `443` (or set up suitable port forwarding) you should be able to access the demo servers at this URL:

```
https://tls-playground.example.net/
```



## TP Server Commands Reference

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
            In all other aspects, this behaves same as the run command.

  reload    Reload configuration of the given TP demo <server> running in the
            background, see start command. This will also load new certificates
            and private key files, if they have changed.

  stop      Stop the given TP demo <server> running in the background, see start
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
