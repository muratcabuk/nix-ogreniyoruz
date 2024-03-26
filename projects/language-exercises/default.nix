let
  functions = import ./functions.nix;
in
{
  result = functions { numbers = [1 2 3 4];   strings = ["Hello" " " "Nix"];};
}
