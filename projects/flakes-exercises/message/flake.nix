 
# flake.nix

{
  description = "Simple Message App with C";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
  };

  outputs ={ self, nixpkgs, ... }:

    let

      simpleMessageAppSrc = "https://github.com/muratcabuk/simple-message-app-with-c/archive/refs/tags/v1.0.tar.gz";

      # Simple Message App'in kaynak dizini
      src = builtins.fetchTarball {
        url = simpleMessageAppSrc;
        sha256 = "sha256:1aai9xdkgq2vd0ch10gxhg53qfv4ny2x3jgxlq4r9nrn4g9r8s1z";
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
        version = "v1.0";
        src = src;
        buildInputs = [ gcc ];
        nativeBuildInputs = [ autoconf libtool makeWrapper ];
        buildPhase = buildCommand;
        installPhase = "mkdir -p $out/bin; install -t $out/bin simple-message-app";

        meta = with nixpkgs.lib; {
          description = "Simple Message App with C";
          license = licenses.mit;
          version = "v1.0";
        };
      };




    };
}
