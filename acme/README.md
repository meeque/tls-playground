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


TODO Document that ACME requires a web server on the public internet with a public DNS record.

TODO Document certbot deviations from TP file naming conventions.

### Initializing ACME Utilities

TODO How to configure an ACME server (prod/stage)

### ACME Account Management

### Controlling ACME http-01 Challenge Server

TODO document lack of suppport for dns-01 challanges, and possible impact on wildcard certificates

TODO document manual challenge solving

### Signing a certificate with ACME

TODO document domain based vs. custom CSR

### Revoking a certificate with ACME



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
            and helps resolving ACME http-01 challenges.
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
            TP and 'certbot' will resolve ACME http-01 challenges automatically.
            But you'll have to start the TPbuilt-in challenges web-server
            before invoking the sign command, see above.
            Alternatively, use the --manual option to resolve challenges
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
            When running the sign command, manually resolve ACME challenges.
            This can be useful when running TP on a host with with a different
            DNS domain name or with no DNS domain name at all. 'certbot' will
            print instructions on how to resolve the challenges.
            Without this option, 'certbot' will use the TP built-in challenges
            web-server to resolve challenges. You will need to start the
            challenges web-server beforehand though, see 'challenges' commands
            above.

Environment:

  Set ${TP_ACME_SERVER_URL} and ${TP_ACME_ACCOUNT_EMAIL} to configure the
  ACME CA to use.

  Set ${TP_SERVER_LISTEN_ADDRESS} and ${TP_SERVER_HTTP_PORT} to configure
  the TP built-in ACME http-01 challenges web-server.

  Run 'tp --help env' to learn more about these env-vars.
```
