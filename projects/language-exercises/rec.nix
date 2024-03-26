let

mySet = rec {a= 1; b= 2; c= 3; d= a + 1;};

in
{
   inherit mySet;
}