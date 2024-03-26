# flake.nix

{
  description = "Simple Message App with C";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
  };

  outputs ={ self, nixpkgs, ... }:

    let
      versionOption = nixpkgs.lib.mkOption {
        default = "v1.0";
        type = builtins.string;
        description = "Version of the Simple Message App";
      };

      selectedVersion = versionOption.default;

      simpleMessageAppSrc = "https://github.com/muratcabuk/simple-message-app-with-c/archive/refs/tags/${selectedVersion}.tar.gz";

      shaSet = {v10="sha256:1aai9xdkgq2vd0ch10gxhg53qfv4ny2x3jgxlq4r9nrn4g9r8s1z";
                v20="sha256:11p3c793yjpm4z4j9shlidbii7wd0kf9qflx8jqhhnwwhqf93mam";
                v30="sha256:1a4a2i32da9shc2d3i1ndarmla97bald7lgs1vjmwyjlry0mk4m7";};

      shaVer = builtins.concatStringsSep "" (nixpkgs.lib.strings.splitString "." "${versionOption.default}");


      versionSha = builtins.getAttr shaVer shaSet;


      # Simple Message App'in kaynak dizini
      src = builtins.fetchTarball {
        url = simpleMessageAppSrc;
        sha256 = versionSha;
      };

       # Programı derleme komutu
      buildCommand = ''
                        gcc -o simple-message-app ${src}/message.c
                     '';

    in
    {

      packages.x86_64-linux.default = with import nixpkgs { system = "x86_64-linux"; };

      stdenv.mkDerivation {
        name = "simple-message-app";
        version = selectedVersion;
        src = src;
        buildInputs = [ gcc ];
        nativeBuildInputs = [ autoconf libtool makeWrapper ];
        buildPhase = buildCommand;
        installPhase = "mkdir -p $out/bin; install -t $out/bin simple-message-app";

        meta = with nixpkgs.lib; {
          description = "Simple Message App with C";
          license = licenses.mit;
          version = selectedVersion;
        };
      };




    };
}
