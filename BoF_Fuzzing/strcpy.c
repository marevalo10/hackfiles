#include <stdio.h> 
#include <string.h>
int main(int argc, char *argv[]) {
    char buffer[64];
    if (argc < 2) {
        printf("Error - You must supply at least one argument\n"); 
        return 1;
    }
    strcpy(buffer, argv[1]); 
    return 0;
}