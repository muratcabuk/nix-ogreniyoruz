{pkgs}:
  let
    app-name = "defaultalt";
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
  }