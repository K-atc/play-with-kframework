#include <stdlib.h>

int bof1(int i) {
    int arr[] = {0, 1, 2, 3};
    return arr[i];
}

int main(int argc, char* argv[]){
    int test_i = 0;
    if (argc > 1) test_i = atoi(argv[1]);
    bof1(test_i);
}