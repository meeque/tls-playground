{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  # These packages will be available in the user's PATH
  nativeBuildInputs =
    import .nix/deps.nix { inherit pkgs; };

  shellHook = ''
    . .bashrc
    echo "Welcome to the TLS Playground environment!"
  '';
}