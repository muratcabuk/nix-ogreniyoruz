let

list1 = [1 2 3 4];
list2 = [5 6 7 8];


mul = my-list1: my-list2: 
                if builtins.length my-list1 > 0 && builtins.length my-list2 > 0 
                    then [(builtins.head my-list1 * builtins.head my-list2)] ++ mul (builtins.tail my-list1) (builtins.tail my-list2)
                else
                    [];
myList = mul list1 list2;

in
{
myList = myList;
list1 =  list1;
list2 =  list2;
}
