{
  description = "Flake için örnek paketler";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs ={ self, nixpkgs, ... }:
    let

        packages = rec {

            x86_64-linux.default = import ./message-app {version = "v3.0";};
            x86_64-linux.message-app = x86_64-linux.default;

            aarch64-linux.message-app =  import ./message-app {version = "v3.0";};
        };

    in
    {
    packages = packages;
    };
}
