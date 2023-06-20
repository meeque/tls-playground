# TLS Playground ACME Commands

This TLS Playground component implements certificate management through the ACME protocol using `certbot`. ACME allows you to obtain domain-validated server certificates from a public CA, like [Let's Encrypt](https://letsencrypt.org/).



## `acme` Commands Summary

```
Usage: tp [<global opions>] acme <command> [<sub-command>]
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
            You should start the challenges web-server before calling the sign
            or renew commands, see below.
            The following challenges sub-commands work in analogy to the respective
            TP server sub-commands:
            run
            start
            reload
            stop

  sign      

  renew     

  revoke    

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

  <cert>    The certificate to revoke.

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

  TP_ACME_ACCOUNT_EMAIL
            Use this email address when registering an ACME account.
            The ACME server does not perform email address verification, but it
            may send notification emails to this address, e.g. certificate
            expiration warnings.
            Defaults to an invalid example address with an .example domain name.
```