{
  description = "Default Alternative App";

  outputs = { self, nixpkgs }: {

    packages.x86_64-linux.default =
      let
        pkgs = import nixpkgs { system = "x86_64-linux"; };

        app-name = "default-alt-app";
        app-script = pkgs.writeShellScriptBin app-name ''
          DATE=$(ddate +'the %e of %B%, %Y')
          cowsay Hello, world! Today is $DATE.
        '';
        app-buildInputs = with pkgs; [ cowsay ddate ];
      in pkgs.symlinkJoin {
        name = app-name;
        paths = [ app-script ] ++ app-buildInputs; # override
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = "wrapProgram $out/bin/${app-name} --prefix PATH : $out/bin";
      };
  };
}
