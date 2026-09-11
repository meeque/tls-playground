{ pkgs ? import <nixpkgs> {} }:

with pkgs;
[
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
]
