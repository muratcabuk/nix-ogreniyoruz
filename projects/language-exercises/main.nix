let
  calc = import ./calculator.nix;
  result = calc { number1 = 30; number2 = 40; };
in
{
  inherit result;
}