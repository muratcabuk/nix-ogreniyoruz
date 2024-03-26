{ lib, config,... }: {
  
  config = { 
    apps.message.iswebsiteBing = lib.mkOverride 50 false; 
    apps.message.list =lib.mkOrder 10 [ "test1" "test2" "test3" ];
    };
  
  }
