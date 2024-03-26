{
  description = "Flake için örnek paketler";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

  };

  outputs ={ self, nixpkgs, flake-utils, ... }:

  let

    systems = ["x86_64-linux" "x86_64-darwin"];

  in

    flake-utils.lib.eachSystem systems (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      {
        packages = rec {
            default = pkgs.callPackage ./apps/default { pkgs = pkgs;};
            defaultalt = pkgs.callPackage ./apps/defaultalt {pkgs = pkgs;};
            defaultfile = pkgs.callPackage ./apps/defaultfile {pkgs = pkgs;};
            message = pkgs.callPackage ./apps/message { version = "v3.0"; pkgs = pkgs;};
            nixapp = pkgs.callPackage ./apps/nixapp {pkgs = pkgs;};
            testapp = pkgs.callPackage ./apps/testapp {version = "v2.0"; pkgs = pkgs;};
        };
      }
    );

}

