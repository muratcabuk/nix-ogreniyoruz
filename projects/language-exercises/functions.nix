{ numbers ? [1 2], strings ? ["merhaba" "nasılsın"] }:

let
  sumNumbers = list: if builtins.length list  > 0 then builtins.foldl' (x: y: x + y) 0 list else 0;
  concatenateStrings = list: if builtins.length list  > 0 then builtins.concatStringsSep " " list else "";
in
{
  sumNumbers = sumNumbers numbers;
  concatenateStrings = concatenateStrings strings;
}