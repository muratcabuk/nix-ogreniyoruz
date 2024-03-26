{
  description = "Merhaba Dünya! için flake";

  # input olarak nixpkgs'i alıyoruz.
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
  };

  # output olarak self ve nixpkgs'i alıyoruz.
  outputs = { self, nixpkgs }: {

    # bu standart olarak kullanılmalı. flake şemasının zorunlu tuttuğu bir attribute
    packages.x86_64-linux.default = with import nixpkgs { system = "x86_64-linux"; };

    stdenv.mkDerivation {
                         name = "merhaba";
                         src = self;
                         buildPhase = "gcc -o merhaba ./merhaba.c";
                         installPhase = "mkdir -p $out/bin; install -t $out/bin merhaba";

    };

    packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;


};
}