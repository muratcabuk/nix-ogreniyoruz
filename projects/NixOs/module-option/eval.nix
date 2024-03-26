
let
  
  system = "x86_64-linux";
  pkgs = import <nixpkgs> {inherit system; config = {allowUnfree = true;}; overlays = []; };

  

in
  pkgs.lib.evalModules {

    modules = [
              # alttaki satırı kapatıp specialArg'ı kullandık. Burada aslında anonymous foksiyon açlıştırıp bir modül döndürüyoruz  aslında.
              # bu modülde bağlı olduğu modün bir argümanını dolduruyor.
              # specialArgs ise doğrudan modülün argumanlarını ekliyor.
              ({ config, ... }: { config._module.args = { pkgs = pkgs; }; })
                ./default.nix
              ];
              #specialArgs = {pkgs = pkgs; };
          
  }