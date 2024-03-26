#include <stdio.h>
#include <stdlib.h>

int main() {
    char firstname[50], lastname[50], word[50];


    printf("Enter your first name: ");
    scanf("%s", firstname);

    printf("Enter your last name: ");
    scanf("%s", lastname);


    printf("Hello, %s %s!\n", firstname, lastname);


    printf("Enter a word: ");
    scanf("%s", word);


    printf("You entered: %s\n", word);


    printf("Press Enter to exit...");
    getchar(); 
    getchar(); 

    return 0;
}