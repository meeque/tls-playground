# TLS Playground Demo CAs

This TLS Playground component implements opinionated, easy to use, but incomplete Certificate Authorities (CAs). It is based on `openssl ca` and other `openssl` commands.

These CAs are not intended for production use, or even for use in a public facing test scenario. It lacks important CA features, like domain ownership verification and certificate revocation. Also, it uses a default passphrase to protect certificate keys.



## `ca` Commands Summary

You can control and utilize the TP CAs with the `tp ca` command:

```
Usage: tp [<global options>] ca <command> [<ca>] [<request>]

Available commands:

  init        Initialize given <ca>, or all TP CAs, if <ca> is omitted.
              Initialization includes creating the necessary directory structures,
              generating a CA root certificate and its private key, creating an
              empty cert DB, etc.

  sign        Sign given <request> with given <ca>.
              Both <ca> and <request> are mandatory for the sign command.
              Signed cert files will be placed next to the <request>.

  clean       Clean up given <ca>, or all TP CAs, if <ca> is omitted.
              Clean up includes deletion of all transient CA files, such as the
              CA root certificate and its private key, the cert DB and the cert archive.

Arguments:

  <ca>        Name of a TP CA.
              Each TP CA is represented by a sub-directory of ${tp_base_dir}/ca/.
              The name of this sub-directory is also the name of the CA.

  <request>   The request to sign.
              This can be either a Certificate Signing Request (CSR) file or
              an 'openssl req' configuration file. If it's the latter,
              the CSR will be generated on the fly before signing.
```



## CA Usage

### Initializing the CA

TP comes with several demo CAs, which are located `${tp_base_dir}/ca/` directory.
Each CA comes with a few static config files that specify the CA's behavior and its root certificate.
During operation, each CA will create a few other files, which it manages in its own directory.

CA initialization will put all the necessary files and directories in place.
You can run initialization for individual CAs, or for all of them at once:

```
tp ca init
```

The most important step in CA initialization is the creation of a **CA root certificate**.
As with other TP certificates, initialization creates the CA root certificate based on an `openssl req` configuration file.
This works the same way as running `tp cert sign`.

Note that this creates a **self-signed certificate**, which is the standard for both public and private CAs.
However, a couple of things distinguish CA root certificates from self-signed certificates that you would use for a server:

1. The certificate subject DN does not contain a DNS domain name.
The CN field simply contains some informal descriptive name.

2. The certificate has an `X509v3 Basic Constraints` extension that says `CA:TRUE`.
Server certificates say `CA:FALSE`, or may omit the extension altogether.

The latter is very important when verifying certificate chains.
If the chain contains a signature from an issues whose certificate does not have `CA:TRUE`, the verification must fail.
In other words, only the leaf certificate may have `CA:FALSE` or omit the extension altogether, but intermediate and root certificates must have `CA:TRUE`.
Note that the TP demo CAs do not make use of intermediate certificates.



### Signing Certificates with the CA

Once a TP demo CA has been initialized, you can use it to sign certificates.
This is very similar to the self-signing a certificate with the `tp cert sign` command.
Here is an example:

```
tp ca sign ca4servers server/nginx-simple/tls/server.cert.conf
```

In the above, `ca4servers` is the name of the TP demo to use and `ca4servers server/nginx-simple/tls/server.cert.conf` is an `openssl req` configuration file.
Instead of such configuration file, you can also pass an existing CSR to `tp ca sign`.

The `tp ca sign` command will initially put the newly signed certificate into the `archive` directory of the CA itself, along with some certificate chain files.
It will then create symlinks to these files and put them next to original `openssl req` configuration file or CSR.
E.g. in the above example, the following new files and symlinks would get created:

```
ca/ca4servers/archive/91F5716800000001.cert.pem
ca/ca4servers/archive/91F5716800000001.chain.pem
ca/ca4servers/archive/91F5716800000001.fullchain.pem
server/nginx-simple/tls/server.cert.pem -> ../../../ca/ca4servers/archive/91F5716800000001.cert.pem
server/nginx-simple/tls/server.chain.pem -> ../../../ca/ca4servers/archive/91F5716800000001.chain.pem
server/nginx-simple/tls/server.fullchain.pem -> ../../../ca/ca4servers/archive/91F5716800000001.fullchain.pem
```

Note that the `91F5716800000001` in the filenames is is a serial number of the newly signed certificate.
The TP demo CAs will increase this serial number for each certificate that they sign.

Also note that symlink will delete any files with the same name that have previously existed.
This may include the results of previous runs of `tp cert sign`, `tp ca sign`, `tp acme sign`, or similar.
The `tp ca sign` command will never delete files in the CA's `archive` directory though.



### Cleaning Up the CA

TODO

