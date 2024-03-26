{
  description = "Dotnet çalışma ortamım";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";

    overlays = [
      (final: prev: rec {
        nodejs = prev.nodejs_18;
        # nodejs paketlerinden birini yüklüyoruz
        pnpm = prev.nodePackages.pnpm;
        # yarn'ı nodejs ile uyumlu yüklüyoruz
        yarn = prev.yarn.override {inherit nodejs;};
      })
    ];

    pkgs = import nixpkgs {inherit system overlays;};
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        dotnet-sdk_8
        # https://github.com/svanderburg/node2nix
        # npm yerine bunu kullanmak özellikle nix paketi oluşturulacaksa daha efektif
        node2nix
        nodejs
        pnpm
        yarn
      ];
    };
  };
}
