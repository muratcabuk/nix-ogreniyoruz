let
myList = [1 2 3 4 5];
result = builtins.map (x : x * 2) myList;
in 
{
inherit result;
}
