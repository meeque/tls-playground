{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  # These packages will be available in the user's PATH
  nativeBuildInputs = [
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
  ];

  shellHook = ''
    . .bashrc
    echo "Welcome to the TLS Playground environment!"
  '';
}