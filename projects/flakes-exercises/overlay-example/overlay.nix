final: prev: {
  defaultapp = import ./pkgs/default {pkgs = final;};
  defaultfile = import ./pkgs/defaultfile {pkgs = final;};
  defaultalt = import ./pkgs/defaultalt {pkgs = final;};
  nixapp = import ./pkgs/nixapp {pkgs = final;};
  message = import ./pkgs/message {
    pkgs = final;
    version = "v3.0";
  };
  testapp = import ./pkgs/testapp {
    pkgs = final;
    version = "v3.0";
  };
  hello-custom = final.hello.overrideAttrs (old: rec {
    name = "hello-custom";
    version = "2.9";
    src = final.fetchurl {
      url = "mirror://gnu/hello/hello-${version}.tar.gz";
      sha256 = "sha256-7Lt6IhQZbFf/k0CqcUWOFVmr049tjRaWZoRpNd8ZHqc=";
    };
  });
}
