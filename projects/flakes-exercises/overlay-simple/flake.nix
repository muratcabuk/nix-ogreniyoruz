{
  description = "Flake için örnek paketler";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };
  outputs ={ self, nixpkgs, ... }:
  let

      overlay = (final: prev: { default = import ./message.nix {pkgs = final; version = "v3.0";}; });

      system = "x86_64-linux";

      pkgs = import nixpkgs { inherit system; overlays = [overlay];};

      packages.x86_64-linux.default = pkgs.default;

  
  in 
  {
    inherit packages;
  };
}