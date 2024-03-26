{
  description = "My Nix Flake";
  inputs = {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:

    let
        pkgs = import nixpkgs {};
        packages = rec {

            x86_64-linux.default = import ./apps/default { pkgs = pkgs;};
            x86_64-linux.defaultalt = import ./apps/defaultalt {pkgs = pkgs;};
            x86_64-linux.defaultfile = import ./apps/defaultfile {pkgs = pkgs;};
            x86_64-linux.message = import ./apps/message { version = "v3.0"; pkgs = pkgs;};
            x86_64-linux.nixapp = import ./apps/nixapp {pkgs = pkgs;};
            x86_64-linux.testapp = import ./apps/testapp {version = "v2.0"; pkgs = pkgs;};
        };
    in
    {
       packages = packages;
    };
}
