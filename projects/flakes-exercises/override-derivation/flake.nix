{
  description = "Flake için örnek paketler";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };
  outputs ={ self, nixpkgs, ... }:
    let


        pkgs = import nixpkgs {};


        # overridederivation : sadece metadata değiştirir.
        # yani hakikaten derivation işlemi başlamadan önceize müdahele edemez
        #packages = rec {
        #    x86_64-linux.default = (pkgs.callPackage ./message-app {nixpkgs = pkgs;}).overrideDerivation (
        #                                        oldAttrs: rec { version = "v3.0";
        #                                                        src = builtins.fetchTarball {
        #                                                                url = "https://github.com/muratcabuk/simple-message-app-with-c/archive/refs/tags/${version}.tar.gz";
        #                                                                sha256 = "sha256:1a4a2i32da9shc2d3i1ndarmla97bald7lgs1vjmwyjlry0mk4m7";};
        #                                                      });


        packages = rec {
           x86_64-linux.default = (pkgs.callPackage ./message-app {nixpkgs = pkgs;}).overrideAttrs (
                                                      finalAttrs: previousAttrs: rec{
                                                                      version = "v3.0";
                                                                      src = builtins.fetchTarball {
                                                                                url = "https://github.com/muratcabuk/simple-message-app-with-c/archive/refs/tags/${version}.tar.gz";
                                                                                sha256 = "sha256:1a4a2i32da9shc2d3i1ndarmla97bald7lgs1vjmwyjlry0mk4m7";};
                                                                                  });

            x86_64-linux.message-app = x86_64-linux.default;

            aarch64-linux.message-app =  import ./message-app {version = "v3.0";};
        };

    in
    {
        packages = packages;
    };
}
