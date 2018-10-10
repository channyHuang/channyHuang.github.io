---
layout: default
---

//Author: channy

//Create Date: 2018-10-06 10:25:19

//Description: 

# Linux_Basic_Comment

## Basic comment

```shell
shutdown -t 0 //shutdown
touch filename //new a file 
rm filename //delete a file
mkdir dir //new a folder
rmdir dir //delete a folder
cp originFile targetFolder //copy a file or folder
mv originFile targetFolder //move a file or folder
```

```c++
int test_perror(const char *s) {
	perror(s);
	exit(1);
	return 0;
}
```

## fork & exec

```c++
#include <stdio.h>
#include <unistd.h>
#include <cstdlib>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/wait.h>

#include "common.cpp"

int test_fork() {
	pid_t pid;
	printf("hello world\n");
	pid = fork();
	if (!pid) {
		printf("child\n");
	} else if (pid > 0) {
		printf("parent\n");
	} else {
		printf("error\n");
	}
	return 0;
}

int test_exec() {
	execl("/bin/ls", "ls", "-l", NULL);
	perror("execl failed\n");
	return 0;
}

int test_failure() {
	char buf[10];
	int fd, pid;
	if ((fd = open("main.cpp", O_RDONLY)) < 0) {
		test_perror("open file failed");
	}
	read(fd, buf, 10);
	long pos;
	if ((pos = lseek(fd, 0L, 1)) < 0L) {
		test_perror("lseek failed");
	}
	printf("Before fork, %ld\n", pos);
	if ((pid = fork()) < 0) {
		test_perror("fork failed");
	} else if (!pid) {
		read(fd, buf, 10);
		if ((pos = lseek(fd, 0L, 1)) < 0L) {
			test_perror("lseek failed");
		}
		printf("After fork, %ld\n", pos);
	} else {
			wait(NULL);
			if ((pos = lseek(fd, 0L, 1)) < 0L) {
				test_perror("lseek failed");
			}
			printf("Parent, %ld\n", pos);
	}
	
	return 0;
}

int main() {
	test_failure();
	
	return 0;
}
```

## environ & gid & uid & nice

```c++
#include <cstdio>
#include <unistd.h>
#include <sys/types.h>
#include <sys/resource.h>

extern char ** environ;

int test_env() {
	char **env = environ;
	while (*env) {
		printf("%s\n", *env++);
	}
	return 0;
}

int test_id() {
	uid_t uid, euid;
	gid_t gid, egid;
	
	uid = getuid();
	euid = geteuid();
	gid = getgid();
	egid = getegid();
	
	printf("%d %d %d %d\n", uid, euid, gid, egid);
	return 0;
}

int main() {
	//test_env();
	test_id();
	nice(5);
	return 0;
}
```

## signal

```c++
```