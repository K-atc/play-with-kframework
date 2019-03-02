#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main(){
    unsigned int count = 0;
    char buf[8];
    setvbuf(stdin, NULL, _IONBF, 0);
    setvbuf(stdout, NULL, _IONBF, 0);
    printf("message length = ");
    fgets(buf, 8, stdin);
    count = atoi(buf);
    printf("%u\n", count);
    if (count > 0) {
        printf("message = ");
        // read(0, buf, count); // c-semantics dissmisses obb-write in read()
        fgets(buf, count, stdin);
        puts(buf);
    }
}