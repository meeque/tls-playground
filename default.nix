let
  pkgs =
    import
      ( fetchTarball "https://github.com/NixOS/nixpkgs/tarball/nixos-25.11" )
      {
        config = {};
        overlays = [];
      };

in
  {
    tp = pkgs.callPackage ./.nix/docker.nix {};
  }
