{
  description = "Default File App";

  outputs = { self, nixpkgs }: {

    packages.x86_64-linux.default =
      let
        pkgs = import nixpkgs { system = "x86_64-linux"; };

        app-name = "default-file-app";

        app-src = builtins.readFile ./script.sh;
        app-script = (pkgs.writeScriptBin app-name app-src).overrideAttrs(old: {
          buildCommand = "${old.buildCommand}\n patchShebangs $out";
        });

        app-buildInputs = with pkgs; [ cowsay ddate ];
      in pkgs.symlinkJoin {
        name = app-name;
        paths = [ app-script ] ++ app-buildInputs; # override
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = "wrapProgram $out/bin/${app-name} --prefix PATH : $out/bin";
      };
  };
}
