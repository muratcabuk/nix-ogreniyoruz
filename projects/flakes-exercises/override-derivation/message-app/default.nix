{nixpkgs ? {}}:
        nixpkgs.stdenv.mkDerivation (finalAttrs: {
              name = "message-app";
              version = "v1.0";

              description = "merhaba dünya";

              src = builtins.fetchTarball {
                      url = "https://github.com/muratcabuk/simple-message-app-with-c/archive/refs/tags/${finalAttrs.version}.tar.gz";
                      sha256 = "sha256:1aai9xdkgq2vd0ch10gxhg53qfv4ny2x3jgxlq4r9nrn4g9r8s1z";
                    };

              buildInputs = [ nixpkgs.gcc ];
              buildPhase = "gcc -o message-app ${finalAttrs.src}/message.c";
              installPhase = "mkdir -p $out/bin; install -t $out/bin message-app";

              meta = with nixpkgs.lib; {
                    description = "Simple Message App with C";
                    license = licenses.mit;
                    version =  "${finalAttrs.version}";
                };
        })
