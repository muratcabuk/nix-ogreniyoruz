{
  description = "Message uygulaması development ortamı";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";

    pkgs = import nixpkgs {inherit system;};

    packages.${system}.default = pkgs.callPackage ./message.nix {pkgs = pkgs;};
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [dotnet-sdk_7];
      inputsFrom = [packages.${system}.default];
    };

    packages = packages;
  };
}
