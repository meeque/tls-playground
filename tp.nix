{
  lib,
  dockerTools,
  runCommand,

  cacert,
  openssl,
  certbot,
  nginx,
  curl,
  sslscan,
  testssl,

  bash,
  coreutils,
  findutils,
  lsof,
  procps,
  getopt,
  less,
  nano,
  man,
}:

let

  fs = lib.fileset;

  tlsPlaygroundSource =
    fs.toSource {
      root = ./.;
      fileset = fs.difference
        (
          fs.gitTracked ./.
        )
        (
          fs.unions [
            ./Dockerfile
            (fs.fileFilter (file: lib.hasPrefix "." file.name || file.hasExt "nix") ./.)
          ]
        );
    };

  tlsPlaygroundFiles =
    runCommand "tls-playground-files" {} ''
      mkdir -p $out/opt/tls-playground
      cp -r ${tlsPlaygroundSource}/. $out/opt/tls-playground/
    '';

in

  dockerTools.buildLayeredImage {
    name = "meeque/tls-playground";
    tag = "nix-latest";

    contents = [
      # tls dependencies
      cacert
      openssl
      certbot
      nginx
      curl
      sslscan
      testssl

      # baseline dependencies
      bash
      coreutils
      findutils
      lsof
      procps
      getopt
      less
      nano
      man

      # custom files
      tlsPlaygroundFiles
    ];

    config = {
      WorkingDir = "/opt/tls-playground";
      Env = [
        "LANG=C.UTF-8"
        "EDITOR=/usr/bin/nano"
        "TP_COLOR=yes"
        "TP_PASS="
        "TP_SERVER_DOMAIN=localhost"
        "TP_SERVER_LISTEN_ADDRESS=127.0.0.1"
        "TP_SERVER_HTTP_PORT=8080"
        "TP_SERVER_HTTPS_PORT=8443"
        "TP_ACME_SERVER_URL=lets-encrypt-staging"
        "TP_ACME_ACCOUNT_EMAIL="
      ];
      Entrypoint = [
        "/bin/sh"
      ];
      Command = [];
      Volumes = {
        "/opt/tls-playground" = {};
      };
      ExposedPorts = {
        "8080/tcp" = {};
        "8443/tcp" = {};
      };
    };
  }
