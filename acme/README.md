# TLS Playground ACME Utiliies

This TLS Playground component implements certificate management through the ACME protocol using `certbot`. ACME allows you to obtain domain-validated server certificates from a public CA, like [Let's Encrypt](https://letsencrypt.org/).



## `acme` Commands Summary

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

Environment variables:

  TP_ACME_SERVER_URL
            Use this http base URL to contact the ACME server.
            Defaults to a URL that represents Let's Encrypt Staging.
            Note that consecutive TP ACME commands may not work as expected,
            if you change this URL in-between.

  TP_ACME_ACCOUNT_EMAIL
            Use this email address when registering an ACME account.
            The ACME server does not perform email address verification, but it
            may send notification emails to this address, e.g. certificate
            expiration warnings.
            Defaults to an invalid example address with an .example domain name.

  TP_SERVER_LISTEN_ADDRESS
            The local address that the TP built-in ACME challenges web-server
            will listen to. See the challenges command.
            To resolve ACME challenges from a public CA this local address must
            receive traffic from the Internet. Use 0.0.0.0 to listen on all
            local addresses.
            Defaults to 127.0.0.1 (localhost), for the sake of attack surface
            reduction. In order to make ACME work, change this to something
            different, or establish some sort of traffic forwarding.

  TP_SERVER_HTTP_PORT
            The local TCP port that the TP built-in challenges web-server will
            listen to. See the challenges command.
            To resolve ACME challenges from a public CA, the challenges
            web-server must be reachable at port 80 from the Internet.
            Defaults to unprivileged port 8080, to allow local testing without
            root privileges. In order to make ACME work, change it to 80, or
            establish some sort of port forwarding.
```
