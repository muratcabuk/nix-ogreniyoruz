{ lib, pkgs,config,... }:

let
      # bir submodule tipi oluşturduk ve içerisine mesage adında bir opsiyon ekledik
      subModuleType = lib.types.submodule {
          options = {
            message = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
            };
          };
      };
in
{
    imports = [
      ./my-module-first.nix
      ./my-module.nix
    ];

    options = {
      scripts.output = lib.mkOption {
          type = lib.types.lines;
      };
  
      scripts.paket = lib.mkOption {
          type = lib.types.package;
      };

    
      mymodules = lib.mkOption {
        # dikkat edilirse subModuleType submodule listesi isteyen bir tip tanımımız var
        type = lib.types.listOf subModuleType;
      };

    };

    config = {
      scripts.output = ''
                      wget https://www.google.com -O /etc/test.txt
                      '';

      scripts.paket = pkgs.writeShellApplication {
                                      name = "create-etc";
                                      runtimeInputs = with pkgs; [ wget ];
                                      text = config.scripts.output;
      };

    mymodules = [
      {message = "Hello World!";}
      {message = "how are you?";}
    ];

    };
}
