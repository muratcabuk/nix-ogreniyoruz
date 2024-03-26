{
  description = "Simple Test App with C";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs ={ self, nixpkgs, ... }:
    let

      selectedVersion = {version = "v1.0";};

      simpleMessageAppSrc = "https://github.com/muratcabuk/simple-message-app-with-c/archive/refs/tags/${selectedVersion.version}.tar.gz";

      shaSet = {v10="sha256:1aai9xdkgq2vd0ch10gxhg53qfv4ny2x3jgxlq4r9nrn4g9r8s1z";
                v20="sha256:11p3c793yjpm4z4j9shlidbii7wd0kf9qflx8jqhhnwwhqf93mam";
                v30="sha256:1a4a2i32da9shc2d3i1ndarmla97bald7lgs1vjmwyjlry0mk4m7";};

      shaVer = builtins.concatStringsSep "" (nixpkgs.lib.strings.splitString "." "${selectedVersion.version}");

      versionSha = builtins.getAttr shaVer shaSet;

      # Simple Message App'in kaynak dizini
      src = builtins.fetchTarball {
        url = simpleMessageAppSrc;
        sha256 = versionSha;
      };

     test-app-derivation = import ./test-app-derivation.nix;

    in
    {
      packages.x86_64-linux.default = with import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };

      test-app-derivation {pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };
                  stdenv = stdenv; gcc = gcc; 
                  selectedVersion = selectedVersion;
                  src = src;};
    };
}
