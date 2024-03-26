
{ lib, pkgs, config,... }: {

    options = {
        
      apps.message.paket = lib.mkOption {
        type = lib.types.package;
      };

      apps.message.iswebsiteBing = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };


      apps.message.list = lib.mkOption {
        type = lib.types.listOf lib.types.str;
      };


    };

    config = lib.mkMerge [ {
                              apps.message.paket = pkgs.writeShellApplication {
                                      name = "hello-app";
                                      runtimeInputs = with pkgs; [ cowsay ];
                                      text = ''
                                                cowsay ${config.scripts.output}
                                              '';
                                  };
                              apps.message.iswebsiteBing = true;

                              apps.message.list = [ "test4" "test5" "test6" ];


                        }

                        
                        (lib.mkIf config.apps.message.iswebsiteBing {
                                              scripts.output = lib.mkOverride 100 ''
                                                          wget https://www.bing.com -O /etc/test.txt
                                                                            ''; })
                        

                    ];
}
