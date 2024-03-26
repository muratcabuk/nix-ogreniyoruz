{
  description = "Flake için örnek paketler";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };
  outputs ={ self, nixpkgs, ... }:
  let
      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-linux"
        "x86_64-linux"
      ];

      overlays = [(import ./overlay.nix)];

      packages = forAllSystems (system:
          let
            pkgs = import nixpkgs {
              inherit system;
              overlays = overlays;
            };
          in {
            default = pkgs.defaultapp; 
            defaultfile = pkgs.defaultfile; 
            defaultalt = pkgs.defaultalt; 
            nixapp = pkgs.nixapp;
            message = pkgs.message; 
            testapp = pkgs.testapp;
            hello = pkgs.hello;
            hello-custom = pkgs.hello-custom;
            }
        );
  in 
  {
    inherit packages;
  };
}