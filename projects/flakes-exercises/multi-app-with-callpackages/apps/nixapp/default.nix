{pkgs}:pkgs.hello.overrideAttrs(oldAttrs: {
  name = "nixapp";})