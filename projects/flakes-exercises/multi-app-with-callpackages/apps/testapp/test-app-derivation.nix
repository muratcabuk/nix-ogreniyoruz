{pkgs, version, src}:

pkgs.stdenv.mkDerivation (finalAttrs: {
              name = "testapp";
              version = "${version}";

              src = src;

              buildInputs = [ pkgs.gcc ];
              buildPhase = "gcc -o testapp ${src}/message.c";
              installPhase = "mkdir -p $out/bin; install -t $out/bin testapp";

              meta = with pkgs.lib; {
                    description = "Simple Test App with C";
                    license = licenses.mit;
                    version =  "${version}";
                };
})
