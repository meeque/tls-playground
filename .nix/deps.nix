{ pkgs ? import <nixpkgs> {} }:

[
  # tls dependencies
  pkgs.cacert
  pkgs.openssl
  pkgs.certbot
  pkgs.nginx
  pkgs.curl
  pkgs.sslscan
  pkgs.testssl

  # baseline dependencies
  pkgs.bash
  pkgs.coreutils
  pkgs.findutils
  pkgs.lsof
  pkgs.procps
  pkgs.getopt
  pkgs.gnused
  pkgs.gettext
  pkgs.less
  pkgs.pstree
  pkgs.nano
  pkgs.man
]
