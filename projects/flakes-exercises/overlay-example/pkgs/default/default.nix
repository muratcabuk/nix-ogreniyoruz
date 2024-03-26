{pkgs}:
pkgs.writeShellScriptBin "default" ''
                DATE="$(${pkgs.ddate}/bin/ddate +'the %e of %B%, %Y')"
                ${pkgs.cowsay}/bin/cowsay Hello, world! This is Default App and  Today is $DATE.
                ''