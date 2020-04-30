#include <stdio.h>
#include <string.h>

#define BUFSIZE 64

int main(int argc, char *argv[])
{
    char buf[BUFSIZE];
    strcpy(buf, argv[1]);
    printf("Buf: %p\n", &buf);
    return 0;
}
