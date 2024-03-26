{
  description = "My Nix Flake";
  inputs = {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };
  outputs = { self, nixpkgs }:

  let

      default-app-flake = import ./default-app/flake.nix;
      default-app-output = default-app-flake.outputs {inherit self; inherit nixpkgs;};

      default-alt-app-flake = import ./default-alt-app/flake.nix;
      default-alt-app-output = default-alt-app-flake.outputs {inherit self; inherit nixpkgs;};

      default-file-app-flake = import ./default-file-app/flake.nix;
      default-file-app-output = default-file-app-flake.outputs {inherit self; inherit nixpkgs;};

      message-app-flake = import ./message-app/flake.nix;
      message-app-output = message-app-flake.outputs {inherit self; inherit nixpkgs;};

      test-app-flake = import ./test-app/flake.nix;
      test-app-output = test-app-flake.outputs {inherit self; inherit nixpkgs;};

      nix-app-flake = import ./nix-app/flake.nix;
      nix-app-output = nix-app-flake.outputs {inherit self; inherit nixpkgs;};

  in
    {
      packages.x86_64-linux.default = default-app-output.packages.x86_64-linux.default;

      packages.x86_64-linux.default-alt-app = default-alt-app-output.packages.x86_64-linux.default;

      packages.x86_64-linux.default-file-app = default-file-app-output.packages.x86_64-linux.default;      

      packages.x86_64-linux.test-app = test-app-output.packages.x86_64-linux.default;

      packages.x86_64-linux.message-app = message-app-output.packages.x86_64-linux.default;

      packages.x86_64-linux.nix-app = nix-app-output.packages.x86_64-linux.default;
    };
}
