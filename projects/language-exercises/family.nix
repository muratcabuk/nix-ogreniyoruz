let

  family = rec {lastname = "Yılmaz";  
                father = {name="Mehmet"; lastname=lastname; age = 40; wife = mother; child = child;};
                mother = {name="Ayşe"; lastname=father.lastname; age = father.age - 3; husband = father; child = child;};
                child = {name="Ali"; lastname=mother.lastname; age = mother.age - 30; mother = mother; father = father;};
                };

in
{
   inherit family;
}