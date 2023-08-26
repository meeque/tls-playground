# TLS Playground ACME Utilities

This TLS Playground module implements certificate management through the [ACME](https://www.rfc-editor.org/rfc/rfc8555.html) protocol.
ACME allows you to obtain domain-validated server certificates from a public CA, like [Let's Encrypt](https://letsencrypt.org/).
Let's Encrypt and the ACME protocol have enabled widespread TLS adoption by offering X.509 certificates at no financial cost and by automating the process of obtaining and revoking certificates.

Like a classic CA, an ACME CA performs **validation of domain ownership** based on single-use security tokens.
The CA asks the domain owner to deploy to a token in a designated location on an HTTP web server running on the domain or in the domain's DNS entries.
This has been a well established approach even before ACME.
But the standardization and automation that ACME offers makes it easy to obtain new certificates at scale.
This allows CAs to issue shorter-lived certificates, which makes compromise of a certificate's private key less catastrophic.
It also allows domain owners to design their domain and sub-domain layout without paying to much attention to the hassle of manual certificate management.
This can be beneficial for security at large, because it allows to make better use of web browsers' same-origin-policy.

The TP ACME Utilities can be controlled through the `tp acme` command of the TP CLI.
Most of the functionality is implemented by invoking commands of the [Certbot](https://certbot.eff.org/) CLI tool, which implements an ACME client.
Observe the outputs of the TP CLI to find out how it makes use of `certbot`.



## ACME Utilities Usage

To make full use of the TP ACME utilities, you will need a **registered DNS domain** and **administrative access to the corresponding host**.
The easiest way is running `tp acme` on the host itself (possibly inside a Docker container), in particular, when there is no other server listening to port 80, the standard HTTP port.

If you want to run the TP CLI on a different host, or if port 80 is already taken, you can still use TP ACME utilities.
It will just need to do some manual interaction, so watch out for the `--manual` flag in the sections below.

TODO Explain that TP uses a custom certbot config and data directory within TP iself and does not touch /etc

### Initializing ACME Utilities

Before using the TP ACME utilities, you will have to initialize them by running the `init` command.
This creates necessary directories and `certbot` configuration files.
Certbot configuration can be customized can be customized using the `${TP_ACME_SERVER_URL}` and `${TP_ACME_ACCOUNT_EMAIL}` environment variables.
Run `tp --help env` to learn more about these env-vars and their defaults.
Then run the following to initialize the TP ACME utilities:

```
tp acme init
```

Note that TP ACME utilities are designed to use a single ACME server at a time.
When you point `${TP_ACME_SERVER_URL}` to a different ACME server, you will have to run `init` again to make the change effective.
Most TP ACME utilities functionality should keep working after switching to a new server.
However, some functionality like certificate renewal or certificate revocation may not work as expected.

It's highly recommended that you first try out TP ACME utilities (or any other ACME client) against a non-production ACME server.
Such server can be used like any other ACME server, but will not issue certificates that standard TLS clients will accept.
This is because a non-production servers use different CA root certificates, which OS and browser vendors do not add to their lists of trusted CAs.

By default, TP ACME utilities use the non-production ACME server from the [Let's Encrypt Staging Environment](https://letsencrypt.org/docs/staging-environment/).
In case of Let's Encrypt, their staging server has another benefit: it enforces more generous quotas on how many certificates you're allowed to request in a day.
This gives you more room for experimentation, before you switch to a production ACME server.

### ACME Account Management

Most ACME operations are bound to an account that an ACME client maintains with an ACME server.
However, account self-registration is possible and `certbot` takes care of it automatically.
It will simply create a new account key-pair and register a new account when your first request a new certificate from an ACME server.
That said, you can also register an ACME account explicitly, by running this command:

```
tp acme account register
```

All ACME operations that can be done with an existing account, can also be done with a new one.
However, reusing an account has some benefits.
Once you've completed domain ownership challenges, the ACME server may store the resulting authorizations with your account and skip further challenges.
E.g., [Let's Encrypt caches these authorizations for 30 days](https://letsencrypt.org/docs/faq/#i-successfully-renewed-a-certificate-but-validation-didn-t-happen-this-time-how-is-that-possible).
An existing account can also be used for revoking certificates that have been issued to the account.
However, there are other alternative for authorizing certificate revocation through ACME.

Once you don't need an account anymore, you can unregister (i.e. close, deactivate) it through ACME.
Note that this will not revoke certificates that have been issued to the account.
Run the following TP CLI command to unregister an ACME account:

```
tp acme account unregister
```

### Controlling the ACME http-01 Challenges Server

Currently, TP ACME utilities only support `http-01`, not `dns-01` challenges.
Unfortunately, this means that TP cannot obtain wildcard certificates from Let's Encrypt, because their policies mandate `dns-01` for wildcards.

While `certbot` provides numerous integrations to automate `http-01` challenges, TP ACME utilities only support the simple [Webroot](https://eff-certbot.readthedocs.io/en/stable/using.html#webroot) integration.
For this integration, `certbot` will simply drop challenge files into some pre-configured directory in the local file-system.
It is up to the `certbot` user to ensure that these challenge files are exposed through a webserver so that the ACME server can verify them through HTTP.

The TP ACME utilities expose challenges through a dedicated nginx webserver, which works quite similar to the nginx servers in the [TP Demo Servers](../server/README.md) module.
While the Demo Servers only accept HTTPS traffic, the Challenges Server only accepts plain HTTP traffic.
In scenarios where only ACME challenges need to be exposed through plain HTTP, this setup of having separate servers for HTTP and HTTPS can be beneficial.
This allows a bootstrapping sequence like the following:

1. Start the plain HTTP server for challenges.
2. Obtain X.509 certificates through ACME.
3. Install the X.509 certificates and corresponding private keys into the configuration of the HTTPS server.
4. Start the HTTPS server with all necessary certificates in place.

Before starting the Challenges Server, you can configure it through the `${TP_SERVER_LISTEN_ADDRESS}` and `${TP_SERVER_HTTP_PORT}` environment variables.
These default to `127.0.0.1` and `8080` respectively.
You will need to adjust them to listen on your Internet-facing IP address (or `0.0.0.0` to listen on all addresses) and on the standard HTTP port `80`.
Alternatively, you can setup some sort of port forwarding to the Callenges Server, e.g. when running TP CLI in a Docker container.
Note that listening to ports below `1000` requires administrative privileges on most Unix systems. 

After changing the above env-vars you will have to initialize TP ACME utilities again, as described in the previous section.
Then you can start the Challenges Server with this command:

```
tp acme challenges start
```

Note that the Challenges Server will accept HTTP requests for all DNS domains that point to its address.
That's why you can use it to obtain certificates for all the TP Demo Servers and their numerous sub-domains.
The server will only serve requests to the challenge files and a simple index page.
It will respond with a generic error page to all other request, mostly with HTTP response status code 404 (Not Found).

The above command starts the Challenges Server in the background, so that you can run other TP commands afterwards.
For example, you could move on to the next section and start obtaining certificates with ACME.
Once you do not need the challenges Server anymore, you can stop it with this command:

```
tp acme challenges start
```

If you cannot run the TP ACME utilties Challenges Server as documented here, you may still be able to complete ACME challenges manually, see instructions in the next section...

### Signing a Certificate with ACME

Once you've come this far, it's time to order your first certificate with ACME.
In this section we'll use the `ecdsa-brainpoolP320r1` sample certificate from the [TP Certificate Utilities](../cert/README.md) module as an example.

First, you'll have to set `${TP_SERVER_DOMAIN}` environment variable to your public DNS domain and initialize the CSR config file:

```
tp cert init cert/good/ecdsa-brainpoolP320r1.cert.conf
```

Note that the resulting CSR config file will actually use a sub-domain of `${TP_SERVER_DOMAIN}`.
If your DNS zone does not resolve arbitrary sub-domains to the same `A` or `AAAA` record, you may need to adjust the domain name in the CSR config file manually.

Now you can place an new ACME order and obtain a signed certificate from the ACME server with this command:

```
tp acme sign cert/good/ecdsa-brainpoolP320r1.cert.conf
```

If your ACME `http-01` Challenges Server is running as per the previous section, the whole process should not take longer than a few seconds.
Like other TP commands, the TP ACME uilities will show how they invoke the `certbot` CLI tool in order to obtain the certificates.
The outputs of `certbot` itself will also be visible, so you can follow what's going on.
Moreover the command will print the locations where the new certificate and related files will be located.
And it will print a textual representation of the certificate and the certificate fingerprint.

Note that `certbot` has it's own file naming conventions, which are slightly different from [TP Filenames and Extensions](../bin/REDME.md#Filenames-and-Extensions).
First, `certbot` puts new certificates into an `archive` directory, which will contain subsequent certificates for the same domains.
`certbot` calls these subsequent certificates a *lineage* and will create an `archive` sub-directory based on the *lineage* name (usually the primary domain name of the certificate).
Then, `certbot` also maintains a `live` directory for each *lineage* and symlinks the latest certificate (and related files) into it.
After running the above command, you should be able to see something like the following symlink files:

```
acme/certbot/conf/live/ecdsa-320.example.tls-playground.example/cert.pem -> ../../archive/ecdsa-320.example.tls-playground.example/cert1.pem
acme/certbot/conf/live/ecdsa-320.example.tls-playground.example/chain.pem -> ../../archive/ecdsa-320.example.tls-playground.example/chain1.pem
acme/certbot/conf/live/ecdsa-320.example.tls-playground.example/fullchain.pem -> ../../archive/ecdsa-320.example.tls-playground.example/fullchain1.pem
acme/certbot/conf/live/ecdsa-320.example.tls-playground.example/privkey.pem -> ../../archive/ecdsa-320.example.tls-playground.example/privkey1.pem
```

Moreover, TP ACME utilties will create additional symlinks next to the original CSR config file:

```
cert/good/ecdsa-brainpoolP320r1.cert.pem -> ../../acme/certbot/conf/archive/ecdsa-320.example.tls-playground.example/cert1.pem
cert/good/ecdsa-brainpoolP320r1.chain.pem -> ../../acme/certbot/conf/archive/ecdsa-320.example.tls-playground.example/chain1.pem
cert/good/ecdsa-brainpoolP320r1.fullchain.pem -> ../../acme/certbot/conf/archive/ecdsa-320.example.tls-playground.example/fullchain1.pem
cert/good/private/ecdsa-brainpoolP320r1.key.pem -> ../../../acme/certbot/conf/archive/ecdsa-320.example.tls-playground.example/privkey1.pem
```

This allows other TP modules to always find certificates and related files in the same locations, following TP file naming conventions.
No matter whether the certificate has self-signed, signed by a TP demo CA, or signed by an ACME CA.
For example, you can use the [TP Demo Servers](../server/README.md) with any of these certificates, just specify the respective CLI option when initializing a demo server.

### Signing a Custom CSR with ACME

When ordering a certificate through ACME, there's still a CSR involved.
However, most `certbot` users will hardly notice, because `certbot` takes care of generating a key-pair and a CSR under the hood.
In the example in the previous section, TP does not deal with the CSR either.
TP just extracts the DNS domain names from the CSR config file and passes them to the `certbot` CLI.
TP doesn't pass any other certificate-specific configuration (e.g. key parameters) to `certbot`, but relies on the defaults from the `certbot` config file (`acme/certbot/cli.ini`).
Also note that `certbot` does not encrypt generated private-key files with a passphrase.

This is convenient for most users, who do not want to think too much about such details.
However, `certbot` offers more control to users who want it - they can simply create a CSR themselves and let `certbot` take it from there.
This is what TP ACME utilities do, when you use the `--csr` option (which makes use of `certbot`'s own `--csr` option):

```
tp acme sign --csr cert/good/ecdsa-brainpoolP320r1.cert.conf
```

When using a custom CSR, `certbot` does not manage certificates and related files in its `archive` directory.
Therefore, TP keeps its own archive directory for ACME certificates obtained through custom CSRs in `acme/certbot/custom/archive/`.
Again, TP creates symlinks according to TP file naming conventions next to the CSR config file:

```
cert/good/ecdsa-brainpoolP320r1.cert.pem -> ../../acme/certbot/custom/archive/00000017.cert.pem
cert/good/ecdsa-brainpoolP320r1.chain.pem -> ../../acme/certbot/custom/archive/00000001.chain.pem
cert/good/ecdsa-brainpoolP320r1.fullchain.pem -> ../../acme/certbot/custom/archive/00000001.fullchain.pem
```

### Completing ACME Challenges Manually


### Revoking a Certificate with ACME



## TP ACME Commands Reference

```
Summary:    TLS Playground ACME Utilities

Usage:      tp [<global options>] acme <command> [<sub-command>]
  [<request>|<cert>] [<options>]

Available commands:

  init      Initialize TP ACME functionality.
            Create directory structures and generate config files for 'certbot'
            and ACME challenges.

  account   Manage ACME accounts and corresponding account private keys.
            If you do not register an account explicitly, 'certbot' will do it
            on-the-fly when requesting a new certificate, see sign command
            below.
            Self-explanatory account sub-commands:
            register
            unregister

  challenges  Control the TP built-in challenges web-server.
            The challenges web-server listens to http (not https) traffic
            and helps completing ACME http-01 challenges.
            (At this time TP does not support other types of challenges, such as
            dns-01.)
            You should start the challenges web-server before calling the sign
            or renew commands, see below.
            The following challenges sub-commands work in analogy to the
            respective TP server sub-commands:
            run
            start
            reload
            stop

  sign      Use 'certbot' and the ACME protocol to send a <request> to a CA
            and obtain a signed certificate. The CA will issue challenges to
            verify control of the DNS domain names listed in the request.
            TP and 'certbot' will complete ACME http-01 challenges automatically.
            But you'll have to start the TPbuilt-in challenges web-server
            before invoking the sign command, see above.
            Alternatively, use the --manual option to complete challenges
            manually, see below.

  renew     Use 'certbot' and the ACME protocol to renew an existing <cert>.
            ACME challenges will be handled as described for the sign
            command above.
            The renew command only works for certificates that 'certbot' manages
            in a so-called certificate lineage. It does not work for
            certificates that have been obtained with the TP ACME --csr option.
            Note that 'certbot' may skip renewal, if the latest certificate in
            the lineages is not about to expire yet.

  revoke    Use 'certbot' and the ACME protocol to revoke an existing <cert>.
            Accepts the following keywords to remove multiple certificates
            at once:
            certbot - all certificates archived in certbot lineages
            csr - all archived certificates obtained with the --csr option
            all - both of the above

  clean     Clean up TP ACME directory structure and config files.
            This will NOT delete existing certificates and keys in the certbot
            archive directories.

Arguments:

  <request> The request to sign.
            An 'openssl req' configuration file that contains the DNS domain
            names to request. Normally, the domain names will extracted from
            the file and will be passed to 'certbot' individually. 'certbot'
            will use defaults for key types, sizes, etc.
            Alternatively use the --csr option to pass an actual CSR to
            'certbot'. If necessary, the CSR will be generated from an
            'openssl req' configuration file.

  <cert>    The path to the certificate file to renew or to revoke.

Options:

  -r, --request, --csr
            When running the sign command, use an existing CSR. Or
            generate it from the 'openssl req' configuration file, if
            necessary, before invoking 'certbot'.
            Without this option, let 'certbot' generate an CSR internally.

  -m, --manual
            When running the sign command, manually complete ACME challenges.
            This can be useful when running TP on a host with with a different
            DNS domain name or with no DNS domain name at all. 'certbot' will
            print instructions on how to complete the challenges.
            Without this option, 'certbot' will use the TP built-in challenges
            web-server to complete challenges. You will need to start the
            challenges web-server beforehand though, see 'challenges' commands
            above.

Environment:

  Set ${TP_ACME_SERVER_URL} and ${TP_ACME_ACCOUNT_EMAIL} to configure the
  ACME CA to use.

  Set ${TP_SERVER_LISTEN_ADDRESS} and ${TP_SERVER_HTTP_PORT} to configure
  the TP built-in ACME http-01 challenges web-server.

  Run 'tp --help env' to learn more about these env-vars.
```
