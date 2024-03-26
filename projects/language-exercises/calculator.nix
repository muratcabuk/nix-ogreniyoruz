
{ 
  calcSet ? { 
    sumSet = { numbers = { number1 = 10; number2 = 20; }; sumResult = 0; }; 
    mulSet = { numbers = { number1 = 10; number2 = 20; }; mulResult = 0; };
    }
}:
let
  sum = x: y: x + y;
  mul = x: y: x * y;
  

  calcResult = {
                  sumResult = with calcSet; sum sumSet.numbers.number1  sumSet.numbers.number2;
                  mulResult = with calcSet; mul mulSet.numbers.number1  mulSet.numbers.number2;
                  allResult = calcSet // { 
                                            sumSet = calcSet.sumSet // {sumResult = sumResult; }; 
                                            mulSet = calcSet.mulSet // { mulResult = mulResult;};
                                          };
                              
              };
in
{
   result = with calcResult;[sumResult mulResult (if sumResult>mulResult 
                                                    then "toplama sonucu çarpmadan daha büyük" 
                                                    else "çarpma sonucu toplamadan daha büyük")
                            ];
}