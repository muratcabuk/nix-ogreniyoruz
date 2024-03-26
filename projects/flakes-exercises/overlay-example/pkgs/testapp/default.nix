{ pkgs, version? "v1.0" }:
    let

      simpleMessageAppSrc = "https://github.com/muratcabuk/simple-message-app-with-c/archive/refs/tags/${version}.tar.gz";

      shaSet = {v10 = "sha256:1aai9xdkgq2vd0ch10gxhg53qfv4ny2x3jgxlq4r9nrn4g9r8s1z";
                v20 = "sha256:11p3c793yjpm4z4j9shlidbii7wd0kf9qflx8jqhhnwwhqf93mam";
                v30 = "sha256:1a4a2i32da9shc2d3i1ndarmla97bald7lgs1vjmwyjlry0mk4m7";};

      shaVer = builtins.concatStringsSep "" (pkgs.lib.strings.splitString "." "${version}");

      versionSha = builtins.getAttr shaVer shaSet;
      
      # Simple Message App'in kaynak dizini
      src = builtins.fetchTarball {
          url = simpleMessageAppSrc;
          sha256 = versionSha;};

      derivation =  import ./test-app-derivation.nix {pkgs=pkgs; version = "${version}"; src = src; };
    in derivation

