let
  myRecList = rec {
                    value = 1; rest = rec {
                                            value = 2; rest = rec {
                                                                    value = 3; rest = null;
                                                                    };
                                          };
                  };
in
{
test = myRecList;
}