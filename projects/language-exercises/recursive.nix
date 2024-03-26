{num? {num = 0;}}:
let
    sumAll = num1: if num1 < 1 then num1 else if  num1 > 1 then num1 + sumAll (num1 - 1) else 1;
in
{
result = sumAll num.num;
}