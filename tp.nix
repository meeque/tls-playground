{
  lib,
  dockerTools,
  nix-gitignore,
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
  gnused,
  gettext,
  pstree,
  less,
  nano,
  man,
}:

let

  tpSource =
    nix-gitignore.gitignoreSource
      [ ./.dockerignore ]
      ./.;

  tpBashRcSource =
    lib.fileset.toSource {
      root = ./.;
      fileset = ./.bashrc;
    };

  rootUid = "0";
  rootGid = "0";
  nobodyUid = "65534";
  nogroupGid = "65534";
  nginxUid = "101";
  nginxGid = "101";

  tpFakeNss =
    dockerTools.fakeNss.override {
      extraPasswdLines = [
        "root:x:${rootUid}:${rootGid}:root:/root:/bin/bash"
        "nobody:x:${nobodyUid}:${nogroupGid}:nginx user:/var/empty:/bin/false"
        "nginx:x:${nginxUid}:${nginxGid}:nginx user:/var/empty:/bin/false"
      ];
      extraGroupLines = [
        "root:x:${rootGid}:"
        "nogroup:x:${nogroupGid}:"
        "nginx:x:${nginxGid}:"
      ];
    };

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
      gnused
      gettext
      less
      pstree
      nano
      man

      # tp config
      tpFakeNss
    ];

    extraCommands = ''
      mkdir -p opt/tls-playground
      cp -r ${tpSource}/. opt/tls-playground/
      cp ${tpBashRcSource}/.bashrc opt/tls-playground/

      mkdir tmp/
      mkdir -p var/log/nginx/
    '';

    config = {
      WorkingDir = "/opt/tls-playground";
      Env = [
        "LANG=C.UTF-8"
        "EDITOR=/usr/bin/nano"
        "HOME=/opt/tls-playground"
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
        "/bin/bash"
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
