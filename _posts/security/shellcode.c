#include <stdio.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
        char *buf[] = {"/bin/sh",NULL};
        execve("/bin/sh", buf, 0);
        return 0;
}

/*
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char *argv[]) {
	char *ptr;

	if(argc < 3) {
		printf("Usage: %s <environment variable> <target program name>\n", argv[0]);
		exit(0);
	}
	ptr = getenv(argv[1]);
	ptr += (strlen(argv[0]) - strlen(argv[2]))*2;
	printf("%s will be at %p\n", argv[1], ptr);
}
*/
