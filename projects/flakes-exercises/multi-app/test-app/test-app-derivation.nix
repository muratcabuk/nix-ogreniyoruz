{pkgs, stdenv, gcc, selectedVersion, src, ...}:

    let

    # Simple Message App'in kaynak dizini
      srcDrv = src;


    in
        stdenv.mkDerivation (finalAttrs: {
              name = "test-app";
              version = "${selectedVersion.version}";

              src = srcDrv;

              buildInputs = [ gcc ];
              buildPhase = "gcc -o test-app ${src}/message.c";
              installPhase = "mkdir -p $out/bin; install -t $out/bin test-app";

              meta = with pkgs.lib; {
                    description = "Simple Test App with C";
                    license = licenses.mit;
                    version =  "${selectedVersion.version}";
                };
        })
