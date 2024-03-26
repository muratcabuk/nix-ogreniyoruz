{pkgs, stdenv, gcc, selectedVersion, src, ...}:

    let

    # Simple Message App'in kaynak dizini
      srcDrv = src;


    in
        stdenv.mkDerivation (finalAttrs: {
              name = "simple-message-app";
              version = "${selectedVersion.version}";

              src = srcDrv;

              buildInputs = [ gcc ];
              buildPhase = "gcc -o simple-message-app ${src}/message.c";
              installPhase = "mkdir -p $out/bin; install -t $out/bin simple-message-app";

              meta = with pkgs.lib; {
                    description = "Simple Message App with C";
                    license = licenses.mit;
                    version =  "${selectedVersion.version}";
                };
        })
